FROM python:2.7

WORKDIR /user/src/app 

COPY test.py ./ 
COPY . .

ENTRYPOINT ["python", "./test.py"]

EXPOSE 5555