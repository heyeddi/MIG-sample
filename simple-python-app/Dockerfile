FROM python:3.12

WORKDIR /code

COPY ./requirements.txt requirements.txt

RUN pip install --no-cache-dir --upgrade -r requirements.txt

COPY ./ ./

# Document that this container uses port 5000
EXPOSE 5000

CMD ["fastapi", "run", "src/simple_python_app/app.py", "--port", "5000"]
