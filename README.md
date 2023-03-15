# gcp-bq-dataset-clone
This is a sample code to clone the bigquery dataset (with no actual copy of data)

## Usage
```sql
BEGIN
  DECLARE source_project_id STRING DEFAULT '<source_project_id>';
  DECLARE source_dataset_id STRING DEFAULT '<source_dataset>';
  DECLARE target_project_id STRING DEFAULT '<source_project_id>';
  DECLARE target_dataset_id STRING DEFAULT '<target_dataset>';
  CALL `<target_dataset>.create_dataset_clone`(source_project_id, source_dataset_id, target_project_id, target_dataset_id);
END;
```