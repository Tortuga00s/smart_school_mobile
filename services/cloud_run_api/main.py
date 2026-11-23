"""Cloud Run integration foundation. Not deployed; no demo identities accepted.
Firebase Auth and privileged Firestore operations share this service boundary.
"""
import re
from typing import Literal
import firebase_admin
from firebase_admin import auth, firestore
from fastapi import Depends, FastAPI, Header, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title='Smart School API', version='0.1.0-foundation')

def db():
    if not firebase_admin._apps:
        firebase_admin.initialize_app()  # Cloud Run service identity / ADC. No key in client.
    return firestore.client()

def identity(authorization: str = Header(default='')):
    if not authorization.startswith('Bearer '):
        raise HTTPException(401, 'Firebase ID token required')
    db()
    try:
        token = auth.verify_id_token(authorization[7:], check_revoked=True)
    except Exception:
        raise HTTPException(401, 'Invalid or revoked ID token')
    profile = db().collection('users').document(token['uid']).get().to_dict()
    if not profile or not profile.get('active') or not profile.get('schoolId'):
        raise HTTPException(403, 'Active school membership required')
    return {'uid': token['uid'], **{k: profile[k] for k in ['role', 'schoolId']}}

def admin(user=Depends(identity)):
    if user['role'] != 'admin':
        raise HTTPException(403, 'Admin only')
    return user

@app.get('/health')
def health():
    return {'service': 'smart-school', 'stage': 'integration-foundation', 'demo': False}

@app.get('/v1/me')
def me(user=Depends(identity)):
    return user

class AssignmentInput(BaseModel):
    teacherUid: str = Field(min_length=1, max_length=128, pattern=r'^[A-Za-z0-9_-]+$')
    subjectId: str = Field(min_length=1, max_length=128, pattern=r'^[A-Za-z0-9_-]+$')
    classId: str = Field(min_length=1, max_length=128, pattern=r'^[A-Za-z0-9_-]+$')
    academicYearId: str = Field(min_length=1, max_length=128, pattern=r'^[A-Za-z0-9_-]+$')

@app.get('/v1/assignments')
def assignments(user=Depends(identity)):
    if user['role'] not in {'admin', 'teacher'}:
        raise HTTPException(403, 'Staff only')
    query = db().collection('teaching_assignments').where('schoolId', '==', user['schoolId'])
    if user['role'] == 'teacher':
        query = query.where('teacherUid', '==', user['uid'])
    return {'items': [{'id': d.id, **d.to_dict()} for d in query.limit(200).stream()], 'limit': 200}

@app.post('/v1/assignments', status_code=201)
def create_assignment(body: AssignmentInput, user=Depends(admin)):
    database = db()
    assignment_id = f"{body.academicYearId}_{body.teacherUid}_{body.subjectId}_{body.classId}"
    ref = database.collection('teaching_assignments').document(assignment_id)
    refs = [('users', body.teacherUid), ('subjects', body.subjectId), ('classes', body.classId), ('academic_years', body.academicYearId)]
    transaction = database.transaction()
    @firestore.transactional
    def write(tx):
        rows = [database.collection(collection).document(key).get(transaction=tx).to_dict() for collection, key in refs]
        for row in rows:
            if not row or row.get('schoolId') != user['schoolId']:
                raise HTTPException(403, 'Cross-school or unknown reference')
        if rows[0].get('role') != 'teacher' or not rows[0].get('active'):
            raise HTTPException(422, 'Active teacher required')
        if ref.get(transaction=tx).exists:
            raise HTTPException(409, 'Assignment already exists')
        tx.create(ref, {**body.model_dump(), 'schoolId': user['schoolId'], 'active': True, 'createdAt': firestore.SERVER_TIMESTAMP, 'createdBy': user['uid']})
        tx.create(database.collection('attendance_audits').document(), {'schoolId': user['schoolId'], 'actorUid': user['uid'], 'action': 'CREATE_ASSIGNMENT', 'assignmentId': assignment_id, 'createdAt': firestore.SERVER_TIMESTAMP})
    write(transaction)
    return {'id': assignment_id}

@app.post('/v1/sessions')
@app.post('/v1/attendance')
@app.post('/v1/proof-access')
def not_implemented(user=Depends(identity)):
    raise HTTPException(501, 'Not implemented: transactional attendance / private evidence pipeline pending')
