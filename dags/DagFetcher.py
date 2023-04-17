from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable

airflow_bucket = Variable.get('airflow_bucket_dags')
airflow_home = Variable.get('airflow_home_dags')

args = {
    'owner': 'Airflow',
    'start_date': days_ago(0),
    'depends_on_past': False
}

folders = ['dags', 'planning', 'quality']

with DAG(dag_id='dags_sync',
         default_args=args,
         schedule_interval='*/5 * * * *',
         tags=['system'],
         catchup=False,
         is_paused_upon_creation=False) as dag:
    tasks = BashOperator(task_id="sync_s3",
                         bash_command=f"aws s3 sync {airflow_bucket} {airflow_home} --delete",
                         dag=dag)