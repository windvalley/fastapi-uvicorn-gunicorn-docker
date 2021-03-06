FROM python:3.8

RUN pip install uvicorn gunicorn fastapi

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./gunicorn_conf.py /gunicorn_conf.py

COPY ./start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

RUN mkdir -p /var/log/gunicorn
VOLUME /var/log/gunicorn

COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80 443

# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["/start.sh"]
