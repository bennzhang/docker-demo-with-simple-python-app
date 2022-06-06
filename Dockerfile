FROM python:2.7


RUN mkdir -p /usr/src/app


WORKDIR /usr/src/app


COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt


COPY . /usr/src/app


EXPOSE 8080
CMD ["python2","/usr/src/app/main.py"]
