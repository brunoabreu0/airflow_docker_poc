#!/usr/bin/env bash

# copy files in EFS volume
cp -R /dags/* /usr/local/airflow/dags/

# start Airflow service as per
#the previous parameter in command container
case "$1" in
  webserver)
        airflow db init \
        && airflow users create \
        --role Admin \
        --username "$(aws ssm get-parameter --name airflow_user)" \
        --password "$(aws secretsmanager get-secret-value --secret-id airflow_password_secret_key)" \
        --email "$(aws ssm get-parameter --name airflow_email)" \
        --firstname airflow \
        --lastname airflow
		sleep 5
    exec airflow webserver
    ;;
  scheduler)
    sleep 15
    exec airflow "$@"
    ;;
  worker)
    sleep 15
    exec airflow celery "$@"
    ;;
  flower)
    sleep 15
    exec airflow celery "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    exec "$@"
    ;;
esac