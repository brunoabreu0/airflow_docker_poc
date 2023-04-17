FROM apache/airflow:2.5.3-python3.8

ENV AIRFLOW_HOME=/usr/local/airflow

USER root

#configs
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN apt-get update
RUN apt-get -y install jq
#COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

#plugins
COPY plugins ${AIRFLOW_HOME}/plugins

#initial dags
COPY dags /dags
RUN mkdir ${AIRFLOW_HOME}/dags

RUN groupadd airflow
RUN chown -R airflow:airflow ${AIRFLOW_HOME}
RUN chmod 777 -R /dags

USER airflow

#requirements
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt


EXPOSE 8080 5555 8793

WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]