"""Copied From https://fastapi.tiangolo.com/tutorial/sql-databases"""

from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from google.cloud.sql.connector import Connector, IPTypes
from google.cloud.secretmanager import SecretManagerServiceClient
import os
import pg8000.dbapi

class Content(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    content: str = Field(index=True)

# Replace with your Cloud SQL instance details
PROJECT_ID = "eddi-sample-project"
REGION = "us-east1"
INSTANCE_NAME = "mig-database"
DATABASE_NAME = "mig-database"
SECRET_NAME = "mig-db-password"
INSTANCE_CONN_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"
DB_USER = "mig-app-user"
# Retrieve DB password from Secret Manager
secret_client = SecretManagerServiceClient()
secret_name = f"projects/{PROJECT_ID}/secrets/{SECRET_NAME}/versions/latest"
response = secret_client.access_secret_version(request={"name": secret_name})
DB_PASSWORD = response.payload.data.decode("UTF-8")
IP_TYPE = IPTypes.PUBLIC if os.environ.get("PUBLIC_IP") else IPTypes.PRIVATE
# initialize Cloud SQL Python Connector object
connector = Connector(refresh_strategy="LAZY")

def getconn():
    conn = connector.connect(
        INSTANCE_CONN_NAME,
        "pg8000",
        user=DB_USER,
        password=DB_PASSWORD,
        db=DATABASE_NAME,
        enable_iam_auth=True,
        ip_type=IP_TYPE,
    )
    return conn

# Create the Engine
engine = create_engine("postgresql+pg8000://", creator=getconn)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]

app = FastAPI()

@app.on_event("startup")
def on_startup():
    create_db_and_tables()


@app.post("/content/")
def create_content(content: Content, session: SessionDep) -> Content:
    session.add(content)
    session.commit()
    session.refresh(content)
    print(f"Content saved: {content.id}")
    return content


@app.get("/content/")
def read_all_content(
    session: SessionDep,
    offset: int = 0,
    limit: Annotated[int, Query(le=100)] = 100,
) -> list[Content]:
    content = session.exec(select(Content).offset(offset).limit(limit)).all()
    return content # type: ignore


@app.get("/content/{content_id}")
def read_content(content_id: int, session: SessionDep) -> Content:
    content = session.get(Content, content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    return content


@app.delete("/content/{content_id}")
def delete_content(content_id: int, session: SessionDep):
    content = session.get(Content, content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    session.delete(content)
    session.commit()
    return {"ok": True}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
