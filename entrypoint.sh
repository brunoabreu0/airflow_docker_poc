#!/usr/bin/env bash

# copy files in EFS volume
cp -R /dags/* /usr/local/airflow/dags/

get_param() {
    P=$(aws ssm get-parameter --name "$1" | jq -r '.Parameter.Value')
    echo "$P"
}

get_secret() {
    S=$(aws secretsmanager get-secret-value --secret-id "$1" | jq -r '.SecretString')
    echo "$S"
}

# start Airflow service as per
#the previous parameter in command container
case "$1" in
  webserver)
        airflow db init \
        && airflow users create \
        --role Admin \
        --username "$(get_param airflow_user)" \
        --password "$(aws secretsmanager get-secret-value --secret-id airflow_password_secret_key)" \
        --email "$(get_param airflow_email)" \
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