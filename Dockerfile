FROM python:3.12-slim

WORKDIR /myapp

COPY . .

RUN pip install -r requirements.txt 

EXPOSE 5000

CMD ["python3", "app.py"]