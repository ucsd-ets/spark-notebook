FROM scnakandala/dsc102-pa2-spark:latest

RUN chmod 777 / && \
    chmod 666 /etc/hosts && \
    mkdir -p /opt/spark/work && \
    chmod 777 -R /opt/spark/work
