# gcp-bq-dataset-clone
This is a sample code to clone the bigquery dataset (with no actual copy of data)

## Instructions
In order to clone the dataset, you need to first create a stored procedure. Run the code [dataset_clone.sql](sql/dataset_clone.sql). Replace some placeholders to make it work in your GCP project.

## Usage
Run the stored procedure with the following snippet:

```sql
BEGIN
  DECLARE source_project_id STRING DEFAULT '<source_project_id>';
  DECLARE source_dataset_id STRING DEFAULT '<source_dataset>';
  DECLARE target_project_id STRING DEFAULT '<source_project_id>';
  DECLARE target_dataset_id STRING DEFAULT '<target_dataset>';
  CALL `<target_dataset>.create_dataset_clone`(source_project_id, source_dataset_id, target_project_id, target_dataset_id);
END;
```