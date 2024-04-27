import uvicorn
import os
import asyncio

from typing import List

from auth import validate_api_key 
from fastapi import FastAPI, UploadFile, Depends
from fastapi.responses import HTMLResponse
from util.text_extraction import extract_text_from_document
from util.task_scheduler import periodic_upload_check
from util.solr import post


app = FastAPI()

@app.get("/client-upload")
async def protected_endpoint(api_key: str = Depends(validate_api_key)):  # Use the dependency if you have auth.py
    return {"message": "Access granted!"}


@app.on_event("startup")
async def startup_event():
    asyncio.create_task(periodic_upload_check())


@app.get("/")
def read_root():
    print("Start")
    p = post("filename", "extracted_text", "file_extension", "file_metadata")
    print("result: ", p)
    print("finished")
    return {"Message": "ePaperless, status ok"}


@app.get("/s3")
def upload_aws_s3():
    # file_path ="./uploads/1713442948981.pdf"

    # Path to the file
    file_path = 'myfile.jpg'

    file_path = os.path.join(os.getcwd(), file_path)
    file_name = os.path.basename(file_path)
    file_extension = os.path.splitext(file_name)[1]
    file_size = os.path.getsize(file_path)
    file_metadata = os.path.getmtime(file_path)

    ocr = extract_text_from_document(file_path)
  

    return {"Message": "Upload to S3 finished", "OCR": ocr}


@app.post("/uploadfiles", dependencies=[Depends(validate_api_key)])
async def create_upload_files(files: List[UploadFile]):
    # Save the files to a folder
    folder = "uploads/"
    os.makedirs(folder, exist_ok=True)  # Ensure the folder exists, create if not

    filenames = []
    for file in files:
        try:
            print(file)
            file_path = os.path.join(folder, file.filename)
            with open(file_path, "wb") as buffer:  # Use synchronous context manager
                buffer.write(await file.read())  # Await reading from the file and write to buffer

        except Exception as error:
            print("An error occurred:", error)

        finally:
            # No need to close file as it's opened using synchronous open
            filenames.append(file.filename)

    return {"filenames": filenames}


@app.get("/upload")
async def main():
    content = """
        <form action="/uploadfiles/" enctype="multipart/form-data" method="post">
        <input name="files" type="file" multiple>
        <input type="submit">
        </form>
        </body>
    """
    return HTMLResponse(content=content)





if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)