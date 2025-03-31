"""Copied From https://fastapi.tiangolo.com/tutorial/sql-databases"""

from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from google.auth import default
from google.auth.transport.requests import Request
import ssl

class Content(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    content: str = Field(index=True)

# Replace with your Cloud SQL instance details
PROJECT_ID = "eddi-sample-project"
REGION = "us-east1"
INSTANCE_NAME = "mig-database"
DATABASE_NAME = "mig-database"

# Construct the Cloud SQL connection string
DATABASE_URL = f"postgresql+pg8000:///{DATABASE_NAME}?host=/cloudsql/{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

# Get default credentials
credentials, project = default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
# Refresh the credentials
credentials.refresh(Request())
# Get the service account email
user_email = credentials.service_account_email.replace(".gserviceaccount.com", "")
# Get the authentication token
auth_token = credentials.token
# Create SSL context
ssl_context = ssl.create_default_context()
# Create SQLAlchemy engine with IAM authentication
engine = create_engine(
    DATABASE_URL,
    connect_args={
        "user": user_email, # Add the user argument
        "password": auth_token,
        "ssl_context": ssl_context,
    },
)

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
