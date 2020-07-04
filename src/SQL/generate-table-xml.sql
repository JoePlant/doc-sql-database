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
			'  <Objects>' as [tableXml],
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
			'  </Objects>' as [tableXml],
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

	UNION ALL	
		select 
			'    <View viewId="' + cast(object_id as varchar) 
			+ '" schema="' + s.name COLLATE DATABASE_DEFAULT
			+ '" name="' + v.name COLLATE DATABASE_DEFAULT
			+ '">' as [tableXml],
			cast(object_id as varchar) + '.0' as [sort_order]
		from 
			sys.views v
		inner join
			sys.schemas s on s.schema_id = v.schema_id

	UNION ALL

		select 
			'      <Column columnId="' + cast(c.column_id as varchar) 
			+ '" name="' + c.name COLLATE DATABASE_DEFAULT
			+ '" type="' + ty.name COLLATE DATABASE_DEFAULT
			+ '" maxLength="' + cast(c.max_length as varchar)
			+ '" precision="' + cast(c.precision as varchar)
			+ '" scale="' + cast(c.scale as varchar)
			+ '"/>' as [xml],
			cast(v.object_id as varchar) + '.' + right('00000' + cast(c.column_id as varchar), 3) as [sort_order]
			--* 
		from sys.views v 
		inner join
			sys.columns c
		on v.object_id = c.object_id
		inner join 
			sys.types ty
		on c.user_type_id = ty.user_type_id 
		--where v.type = 'U'
		
	UNION ALL
		select 
			'    </View>' as [tableXml],
			cast(object_id as varchar) + '.999' as [sort_order]
		from 
			sys.views v

 -- STORED PROCEDURES
	UNION ALL	
		select 
			'    <Procedure procedureId="' + cast(object_id as varchar) 
			+ '" schema="' + s.name COLLATE DATABASE_DEFAULT
			+ '" name="' + p.name COLLATE DATABASE_DEFAULT
			+ '">' as [tableXml],
			cast(object_id as varchar) + '.0' as [sort_order]
		from 
			sys.procedures p
		inner join
			sys.schemas s on s.schema_id = p.schema_id

	UNION ALL
		select 
			'    </Procedure>' as [tableXml],
			cast(object_id as varchar) + '.999' as [sort_order]
		from 
			sys.procedures p

 -- Functions
	UNION ALL	
		select 
			'    <Function functionId="' + cast(object_id as varchar) 
			+ '" schema="' + s.name COLLATE DATABASE_DEFAULT
			+ '" name="' + o.name COLLATE DATABASE_DEFAULT
			+ '">' as [tableXml],
			cast(object_id as varchar) + '.0' as [sort_order]
		from 
			sys.objects o
		inner join
			sys.schemas s on s.schema_id = o.schema_id
		WHERE
			o.type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
				--	From http://msdn.microsoft.com/en-us/library/ms177596.aspx:
				--		FN SQL_SCALAR_FUNCTION
				--		FS Assembly (CLR) scalar-function
				--		FT Assembly (CLR) table-valued function
				--		IF SQL_INLINE_TABLE_VALUED_FUNCTION
				--		TF SQL_TABLE_VALUED_FUNCTION
	UNION ALL
		select 
			'    </Function>' as [tableXml],
			cast(object_id as varchar) + '.999' as [sort_order]
		from 
			sys.objects o
		WHERE
			o.type IN (N'FN', N'IF', N'TF', N'FS', N'FT')

-- Referencing objects
	UNION ALL
		select	
			'      <Reference name="' + OBJECT_NAME(s.referencing_id) COLLATE DATABASE_DEFAULT
			+ '" refName="' + ISNULL(OBJECT_NAME(s.referenced_id), s.referenced_entity_name) COLLATE DATABASE_DEFAULT
			+ '" objectId="' + cast(s.referencing_id as varchar) 
			+ CASE WHEN s.referencing_minor_id = 0 THEN '' ELSE '" columnId="' + cast(s.referencing_minor_id  as varchar) END
			+ ISNULL('" refObjectId="' + ISNULL(cast(s.referenced_id as varchar), OBJECT_ID(s.referenced_entity_name)), '') 
			+ CASE WHEN s.referenced_minor_id = 0 THEN '' ELSE '" refColumnId="' + cast(s.referenced_minor_id as varchar) END
			+ '"/>' as [tableXml],
			cast(s.referencing_id as varchar) + '.0000.' + right('000' + cast(s.referenced_minor_id as varchar), 3) as [sort_order]
		from 
			sys.sql_expression_dependencies s
		where 
			s.referencing_id in 
				(
					select o.object_id--, o.type, o.type_desc
					from sys.objects o
					where o.type not in (
						 'S'	-- SYSTEM_TABLE
						,'IT'	-- INTERNAL_TABLE
						,'TT'	-- TYPE_TABLE
						,'D'	-- DEFAULT_CONSTRAINT
						,'PK'	-- PRIMARY_KEY_CONSTRAINT
						,'UQ'	-- UNIQUE_CONSTRAINT
						,'F'	-- FOREIGN_KEY_CONSTRAINT
						,'C'	-- CHECK_CONSTRAINT
						,'TR'	-- SQL_TRIGGER
						,'SQ'	-- SERVICE_QUEUE
					)
				)
	) qry
order by qry.sort_order
