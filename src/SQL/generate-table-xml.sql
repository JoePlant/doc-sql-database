/*
	generate-table-xml.sql will document the Tables, Columns and Foreign keys from a database as an Xmldocument.
*/

select 
	tableXml
from 
	(
		select 
			'<Database name="'+ db.name COLLATE DATABASE_DEFAULT
			+ '" collation="' + db.collation_name COLLATE DATABASE_DEFAULT
			+ '" compatibilityLevel="' + cast(db.compatibility_level as varchar)
			+ '" createDate="' + cast(db.create_date as varchar)
			+ '">' as [tableXml],
			'0.1' as [sort_order]
		from 
			sys.databases db
		where 
			database_id = DB_ID()
	UNION ALL
		select
			'  <File name="' + mf.name COLLATE DATABASE_DEFAULT
			+ '" type="' + mf.type_desc COLLATE DATABASE_DEFAULT
			+ '" physical="' + mf.physical_name COLLATE DATABASE_DEFAULT
			+ '"/>' as [tableXml],
			'0.1.0' + cast(mf.file_id as varchar) as [sort_order]
		from 
			sys.master_files mf
		where 
			database_id = DB_ID()

	UNION ALL
		select 
			'  <Tables>' as [tableXml],
			'0.2' as [sort_order]
	UNION ALL
		select 
			'    <Table tableId="' + cast(object_id as varchar) 
			+ '" schema="' + s.name COLLATE DATABASE_DEFAULT
			+ '" name="' + t.name COLLATE DATABASE_DEFAULT
			+ '">' as [tableXml],
			cast(object_id as varchar) + '.0' as [sort_order]
		from 
			sys.tables t
		inner join
			sys.schemas s on s.schema_id = t.schema_id
	UNION ALL
		select 
			'      <Rows count="' + cast(p.rows as varchar) + '"/>' as [xml],
			cast(t.object_id as varchar) + '.00' as [sort_order] 
		from
			sys.tables t	
		inner join
			sys.indexes i ON t.object_id = i.object_id
		inner join
			sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
		where 
			t.name not like 'dt%' 
			and i.object_id > 255 
			and i.index_id <= 1
		group by 
			t.object_id, p.rows	
	UNION ALL
		select 
			'      <Column columnId="' + cast(c.column_id as varchar) 
			+ '" name="' + c.name COLLATE DATABASE_DEFAULT
			+ '" type="' + ty.name COLLATE DATABASE_DEFAULT
			+ '" maxLength="' + cast(c.max_length as varchar)
			+ '" precision="' + cast(c.precision as varchar)
			+ '" scale="' + cast(c.scale as varchar)
			+ '"/>' as [xml],
			cast(t.object_id as varchar) + '.' + right('00000' + cast(c.column_id as varchar), 3) as [sort_order]
			--* 
		from sys.tables t 
		inner join
			sys.columns c
		on t.object_id = c.object_id
		inner join 
			sys.types ty
		on c.user_type_id = ty.user_type_id 
		where t.type = 'U'
	UNION ALL
		select 
			'    </Table>' as [tableXml],
			cast(object_id as varchar) + '.999' as [sort_order]
		from 
			sys.tables t
	UNION ALL
		select
			'  </Tables>' as [tableXml],
			'99999999999999.999' as [sort_order]
	UNION ALL
		select
			'</Database>' as [tableXml],
			'99999999999999.9999' as [sort_order]	
	UNION ALL
		select	
			'      <ForeignKey name="' + fk.name COLLATE DATABASE_DEFAULT
			--+ '" tableId="' + cast(fkc.parent_object_id as varchar) 
			+ '" columnId="' + cast(fkc.parent_column_id as varchar)
			+ '" refTableId="' + CAST(fkc.referenced_object_id as varchar)
			+ '" refColumnId="' + CAST(fkc.referenced_column_id as varchar)
			+ '"/>' as [tableXml],
			cast(fkc.parent_object_id as varchar) + '.000.' + right('000' + cast(fkc.parent_column_id as varchar), 3) as [sort_order]
		from 
			sys.foreign_key_columns fkc
		inner join 
			sys.foreign_keys fk
		on 
			fk.object_id = fkc.constraint_object_id

	) qry
order by qry.sort_order
