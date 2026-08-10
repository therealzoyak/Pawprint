import json
import os

from fastapi import FastAPI, HTTPException
from openai import OpenAI
from pydantic import BaseModel, Field


app = FastAPI(title="Pawprint Ask Fetch")
client = OpenAI()
MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6-terra")


class Candidate(BaseModel):
    id: str
    title: str
    description: str
    category: str
    durationMinutes: int
    materials: list[str]


class FetchRequest(BaseModel):
    question: str = Field(min_length=1, max_length=500)
    petName: str
    species: str
    age: str
    energy: str
    limitations: list[str]
    availableMaterials: list[str]
    candidates: list[Candidate] = Field(min_length=1, max_length=20)


class FetchResponse(BaseModel):
    activityID: str
    answer: str


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/fetch", response_model=FetchResponse)
def ask_fetch(request: FetchRequest) -> FetchResponse:
    candidate_data = [candidate.model_dump() for candidate in request.candidates]
    prompt = {
        "question": request.question,
        "pet": {
            "name": request.petName,
            "species": request.species,
            "age": request.age,
            "energy": request.energy,
            "limitations": request.limitations,
            "available_materials": request.availableMaterials,
        },
        "safe_candidate_activities": candidate_data,
    }

    try:
        response = client.responses.create(
            model=MODEL,
            reasoning={"effort": "low"},
            instructions=(
                "You are Fetch, Pawprint's warm and practical pet-activity guide. "
                "Understand the owner's meaning, constraints, mood, and desired effort. "
                "Choose exactly one activity only from safe_candidate_activities. "
                "Never invent an activity or override a pet limitation. Use the candidate's exact id. "
                "Write 2-4 friendly sentences: name the activity naturally, explain why it fits the request and pet, "
                "and give one simple way to begin. Avoid baby talk, judgment, and claims of veterinary expertise."
            ),
            input=json.dumps(prompt),
            text={
                "format": {
                    "type": "json_schema",
                    "name": "fetch_recommendation",
                    "strict": True,
                    "schema": {
                        "type": "object",
                        "properties": {
                            "activityID": {"type": "string"},
                            "answer": {"type": "string"},
                        },
                        "required": ["activityID", "answer"],
                        "additionalProperties": False,
                    },
                }
            },
        )
        result = FetchResponse.model_validate_json(response.output_text)
    except Exception as exc:
        raise HTTPException(status_code=502, detail="The AI helper is temporarily unavailable.") from exc

    allowed_ids = {candidate.id for candidate in request.candidates}
    if result.activityID not in allowed_ids:
        raise HTTPException(status_code=502, detail="The AI helper returned an invalid activity.")
    return result
