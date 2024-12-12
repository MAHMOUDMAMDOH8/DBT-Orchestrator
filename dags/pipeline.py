from airflow.utils.task_group import TaskGroup
from airflow.operators.bash import BashOperator
from airflow import DAG
from airflow.utils.dates import days_ago
import os

default_args = {
    'owner':'ma7moud',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
}

dag = DAG(
    'dbt_orchestrator', 
    default_args=default_args,
    description='dbt_orchestrator Pipeline',
    schedule_interval='*/15 * * * *', 
    start_date=days_ago(1),
    catchup=False,
)

profiles_path = '/opt/airflow/dbt/profiles.yml'
project_path = '/opt/airflow/dbt/ecommerce/dbt_project.yml'

with dag:
    with TaskGroup("test_connection",dag=dag) as test_cconnection:
        dbt_test_connection =BashOperator(
            task_id = 'dbt_test_connection',
            bash_command = f"dbt debug --profiles-dir {os.path.dirname(profiles_path)} --project-dir {os.path.dirname(project_path)}"
        )

    with TaskGroup("run_snapshot",dag=dag) as dbt_run_snapshot:
        dbt_snapshot_task = BashOperator(
            task_id='dbt_snapshot',
            bash_command=f"dbt snapshot --profiles-dir {os.path.dirname(profiles_path)} --project-dir {os.path.dirname(project_path)}",
        )
    with TaskGroup("dbt_run_staging",dag=dag) as dbt_run_staging_group:
        staging_models = ['stg_brand','stg_customers','stg_date','stg_order','stg_order_details','stg_product','stg_store','stg_suppliers']
        dbt_run_staging_tasks = []
        for model in staging_models:
            dbt_run_task = BashOperator(
                task_id=f'dbt_run_{model}',
                bash_command=f"dbt run --profiles-dir {os.path.dirname(profiles_path)} --project-dir {os.path.dirname(project_path)} --models {model}",
            )
            dbt_run_staging_tasks.append(dbt_run_task)
    with TaskGroup('dbt_run_dimensions', dag=dag) as dbt_run_dimensions_group:
        dimension_models = ['brand_dim', 'customer_dim','date_dim','product_dim','store_dim','supplier_dim']
        dbt_run_dimension_tasks = []
        for model in dimension_models:
            dbt_run_task = BashOperator(
                task_id=f'dbt_run_{model}',
                bash_command=f"dbt run --profiles-dir {os.path.dirname(profiles_path)} --project-dir {os.path.dirname(project_path)} --models {model}",
            )
            dbt_run_dimension_tasks.append(dbt_run_task)
    with TaskGroup('dbt_run_fact', dag=dag) as dbt_run_fact_group:
        fact_models = ['fact_sales']
        dbt_run_fact_tasks = []
        for model in fact_models:
            dbt_run_task = BashOperator(
                task_id=f'dbt_run_fact_model_{model}',
                bash_command=f"dbt run --profiles-dir {os.path.dirname(profiles_path)} --project-dir {os.path.dirname(project_path)} --models {model}",
            )
            dbt_run_fact_tasks.append(dbt_run_task)


    dbt_test_task = BashOperator(
        task_id='dbt_test',
        bash_command=f"dbt test --profiles-dir {os.path.dirname(profiles_path)} --project-dir {os.path.dirname(project_path)}",
        )

    test_cconnection>>dbt_run_snapshot>>dbt_run_staging_group>>dbt_run_dimensions_group>>dbt_run_fact_group>>dbt_test_task