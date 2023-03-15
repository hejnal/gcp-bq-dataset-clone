-- define the procedure
CREATE OR REPLACE PROCEDURE <target_dataset>.create_dataset_clone(source_project_id STRING, source_dataset_id STRING, target_project_id STRING, target_dataset_id STRING)
BEGIN
  DECLARE db_objects ARRAY<STRUCT<project_id STRING, object_dataset STRING, object_name STRING, ddl STRING, object_type STRING>>;
  EXECUTE IMMEDIATE FORMAT("WITH all_objects AS (SELECT STRUCT(table_catalog AS project_id, table_schema AS object_dataset, table_name AS object_name, ddl, table_type AS object_type) AS db_objects, creation_time AS creation_time FROM %s.%s.INFORMATION_SCHEMA.TABLES WHERE table_schema = ? UNION ALL SELECT STRUCT(routine_catalog AS project_id, routine_schema AS object_dataset, routine_name AS object_name, ddl, routine_type AS object_type) AS db_objects, created AS creation_time FROM %s.%s.INFORMATION_SCHEMA.ROUTINES WHERE routine_schema = ?) SELECT ARRAY_AGG(db_objects ORDER BY creation_time ASC) AS db_objects FROM all_objects", source_project_id, source_dataset_id, source_project_id, source_dataset_id) INTO db_objects USING source_dataset_id, source_dataset_id;

  FOR db_object IN (SELECT * FROM UNNEST(db_objects))
  DO
    BEGIN
      CASE 
        WHEN db_object.object_type = 'BASE TABLE' THEN
          EXECUTE IMMEDIATE FORMAT("CREATE OR REPLACE TABLE `%s.%s.%s` CLONE `%s.%s.%s`", target_project_id, target_dataset_id, db_object.object_name, db_object.project_id, db_object.object_dataset, db_object.object_name);
        WHEN db_object.object_type = 'EXTERNAL' THEN
          EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(db_object.ddl, source_project_id, target_project_id), source_dataset_id, target_dataset_id), "CREATE EXTERNAL TABLE", "CREATE OR REPLACE EXTERNAL TABLE");
          EXECUTE IMMEDIATE FORMAT("CREATE EXTERNAL TABLE `%s.%s.%s` CLONE `%s.%s.%s`", target_project_id, target_dataset_id, db_object.object_name, db_object.project_id, db_object.object_dataset, db_object.object_name);
        WHEN db_object.object_type = 'VIEW' THEN
          EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(db_object.ddl, source_project_id, target_project_id), source_dataset_id, target_dataset_id), "CREATE VIEW", "CREATE OR REPLACE VIEW");
        WHEN db_object.object_type = 'MATERIALIZED VIEW' THEN
          EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(db_object.ddl, source_project_id, target_project_id), source_dataset_id, target_dataset_id), "CREATE MATERIALIZED VIEW", "CREATE MATERIALIZED VIEW IF NOT EXISTS");
        WHEN db_object.object_type = 'PROCEDURE' OR db_object.object_type = 'FUNCTION' THEN
        EXECUTE IMMEDIATE REPLACE(REPLACE(REPLACE(db_object.ddl, source_project_id, target_project_id), source_dataset_id, target_dataset_id), "CREATE PROCEDURE", "CREATE OR REPLACE PROCEDURE");
      END CASE;
    EXCEPTION WHEN ERROR THEN
      SELECT @@error.message AS message, @@error.statement_text AS original_statement;
  END;
  END FOR;
END;

-- run the procedure
BEGIN
  DECLARE source_project_id STRING DEFAULT '<source_project_id>';
  DECLARE source_dataset_id STRING DEFAULT '<source_dataset>';
  DECLARE target_project_id STRING DEFAULT '<source_project_id>';
  DECLARE target_dataset_id STRING DEFAULT '<target_dataset>';
  CALL `<target_dataset>.create_dataset_clone`(source_project_id, source_dataset_id, target_project_id, target_dataset_id);
END;