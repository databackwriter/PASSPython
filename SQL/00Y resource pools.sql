--from https://docs.microsoft.com/en-gb/sql/advanced-analytics/administration/how-to-create-a-resource-pool?view=sql-server-2017

--Use a statement such as the following to check the resources allocated to the default pool for the server.
SELECT * FROM sys.resource_governor_resource_pools WHERE name = 'default'

--Check the resources allocated to the default external resource pool.
SELECT * FROM sys.resource_governor_external_resource_pools WHERE name = 'default'


ALTER RESOURCE POOL "default" WITH (max_memory_percent = 20);
ALTER EXTERNAL RESOURCE POOL "default" WITH (max_memory_percent = 80);

ALTER RESOURCE GOVERNOR RECONFIGURE;