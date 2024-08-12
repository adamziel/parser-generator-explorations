query
  = EOF
  / ((simpleStatement / beginWork) ((SEMICOLON_SYMBOL EOF?) / EOF))

simpleStatement
  = alterStatement
  / createStatement
  / dropStatement
  / renameTableStatement
  / truncateTableStatement
  / importStatement
  / callStatement
  / deleteStatement
  / doStatement
  / handlerStatement
  / insertStatement
  / loadStatement
  / replaceStatement
  / selectStatement
  / updateStatement
  / transactionOrLockingStatement
  / replicationStatement
  / preparedStatement
  / cloneStatement
  / accountManagementStatement
  / tableAdministrationStatement
  / installUninstallStatment
  / setStatement
  / showStatement
  / resourceGroupManagement
  / otherAdministrativeStatement
  / utilityStatement
  / getDiagnostics
  / signalStatement
  / resignalStatement

alterStatement
  = ALTER_SYMBOL (alterTable / alterDatabase / (PROCEDURE_SYMBOL procedureRef routineAlterOptions?) / (FUNCTION_SYMBOL functionRef routineAlterOptions?) / alterView / alterEvent / alterTablespace / alterUndoTablespace / alterLogfileGroup / alterServer / (INSTANCE_SYMBOL ROTATE_SYMBOL textOrIdentifier MASTER_SYMBOL KEY_SYMBOL))

alterDatabase
  = DATABASE_SYMBOL schemaRef (createDatabaseOption+ / (UPGRADE_SYMBOL DATA_SYMBOL DIRECTORY_SYMBOL NAME_SYMBOL))

alterEvent
  = definerClause? EVENT_SYMBOL eventRef (ON_SYMBOL SCHEDULE_SYMBOL schedule)? (ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL)? (RENAME_SYMBOL TO_SYMBOL identifier)? (ENABLE_SYMBOL / (DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?))? (COMMENT_SYMBOL textLiteral)? (DO_SYMBOL compoundStatement)?

alterLogfileGroup
  = LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef ADD_SYMBOL UNDOFILE_SYMBOL textLiteral alterLogfileGroupOptions?

alterLogfileGroupOptions
  = alterLogfileGroupOption (COMMA_SYMBOL? alterLogfileGroupOption)*

alterLogfileGroupOption
  = tsOptionInitialSize / tsOptionEngine / tsOptionWait

alterServer
  = SERVER_SYMBOL serverRef serverOptions

alterTable
  = onlineOption? IGNORE_SYMBOL? TABLE_SYMBOL tableRef alterTableActions?

alterTableActions
  = (alterCommandList (partitionClause / removePartitioning)?) / partitionClause / removePartitioning / ((alterCommandsModifierList COMMA_SYMBOL)? standaloneAlterCommands)

alterCommandList
  = alterCommandsModifierList / ((alterCommandsModifierList COMMA_SYMBOL)? alterList)

alterCommandsModifierList
  = alterCommandsModifier (COMMA_SYMBOL alterCommandsModifier)*

standaloneAlterCommands
  = (DISCARD_SYMBOL TABLESPACE_SYMBOL) / (IMPORT_SYMBOL TABLESPACE_SYMBOL) / alterPartition / (SECONDARY_LOAD_SYMBOL / SECONDARY_UNLOAD_SYMBOL)

alterPartition
  = (ADD_SYMBOL PARTITION_SYMBOL noWriteToBinLog? (partitionDefinitions / (PARTITIONS_SYMBOL real_ulong_number))) 
  / (DROP_SYMBOL PARTITION_SYMBOL identifierList) 
  / (REBUILD_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList) 
  / (OPTIMIZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList noWriteToBinLog?) 
  / (ANALYZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList) 
  / (CHECK_SYMBOL PARTITION_SYMBOL allOrPartitionNameList checkOption*) 
  / (REPAIR_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList repairType*) 
  / (COALESCE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? real_ulong_number) 
  / (TRUNCATE_SYMBOL PARTITION_SYMBOL allOrPartitionNameList) 
  / (REORGANIZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? (identifierList INTO_SYMBOL partitionDefinitions)?) 
  / (EXCHANGE_SYMBOL PARTITION_SYMBOL identifier WITH_SYMBOL TABLE_SYMBOL tableRef withValidation?) 
  / (DISCARD_SYMBOL PARTITION_SYMBOL allOrPartitionNameList TABLESPACE_SYMBOL) 
  / (IMPORT_SYMBOL PARTITION_SYMBOL allOrPartitionNameList TABLESPACE_SYMBOL)

alterList
  = (alterListItem / createTableOptionsSpaceSeparated) (COMMA_SYMBOL (alterListItem / alterCommandsModifier / createTableOptionsSpaceSeparated))*

alterCommandsModifier
  = alterAlgorithmOption / alterLockOption / withValidation

alterListItem
  = (ADD_SYMBOL COLUMN_SYMBOL? ((identifier fieldDefinition checkOrReferences? place?) / (OPEN_PAR_SYMBOL tableElementList CLOSE_PAR_SYMBOL))) 
  / (ADD_SYMBOL tableConstraintDef) 
  / (CHANGE_SYMBOL COLUMN_SYMBOL? columnInternalRef identifier fieldDefinition place?) 
  / (MODIFY_SYMBOL COLUMN_SYMBOL? columnInternalRef fieldDefinition place?) 
  / (DROP_SYMBOL ((COLUMN_SYMBOL? columnInternalRef restrict?) / (FOREIGN_SYMBOL KEY_SYMBOL (columnInternalRef / columnInternalRef?)) / (PRIMARY_SYMBOL KEY_SYMBOL) / (keyOrIndex indexRef) / (CHECK_SYMBOL identifier) / (CONSTRAINT_SYMBOL identifier))) 
  / (DISABLE_SYMBOL KEYS_SYMBOL) 
  / (ENABLE_SYMBOL KEYS_SYMBOL) 
  / (ALTER_SYMBOL COLUMN_SYMBOL? columnInternalRef ((SET_SYMBOL DEFAULT_SYMBOL (exprWithParentheses / signedLiteral)) / (DROP_SYMBOL DEFAULT_SYMBOL))) 
  / (ALTER_SYMBOL INDEX_SYMBOL indexRef visibility) 
  / (ALTER_SYMBOL CHECK_SYMBOL identifier constraintEnforcement) 
  / (ALTER_SYMBOL CONSTRAINT_SYMBOL identifier constraintEnforcement) 
  / (RENAME_SYMBOL COLUMN_SYMBOL columnInternalRef TO_SYMBOL identifier) 
  / (RENAME_SYMBOL (TO_SYMBOL / AS_SYMBOL)? tableName) 
  / (RENAME_SYMBOL keyOrIndex indexRef TO_SYMBOL indexName) 
  / (CONVERT_SYMBOL TO_SYMBOL charset (DEFAULT_SYMBOL / charsetName) collate?) 
  / FORCE_SYMBOL 
  / (ORDER_SYMBOL BY_SYMBOL alterOrderList) 
  / (UPGRADE_SYMBOL PARTITIONING_SYMBOL)

place
  = (AFTER_SYMBOL identifier) / FIRST_SYMBOL

restrict
  = RESTRICT_SYMBOL / CASCADE_SYMBOL

alterOrderList
  = identifier direction? (COMMA_SYMBOL identifier direction?)*

alterAlgorithmOption
  = ALGORITHM_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL / identifier)

alterLockOption
  = LOCK_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL / identifier)

indexLockAndAlgorithm
  = (alterAlgorithmOption alterLockOption?) / (alterLockOption alterAlgorithmOption?)

withValidation
  = (WITH_SYMBOL / WITHOUT_SYMBOL) VALIDATION_SYMBOL

removePartitioning
  = REMOVE_SYMBOL PARTITIONING_SYMBOL

allOrPartitionNameList
  = ALL_SYMBOL / identifierList

alterTablespace
  = TABLESPACE_SYMBOL tablespaceRef (((ADD_SYMBOL / DROP_SYMBOL) DATAFILE_SYMBOL textLiteral alterTablespaceOptions?) 
  / (() 
  / (CHANGE_SYMBOL DATAFILE_SYMBOL textLiteral (changeTablespaceOption (COMMA_SYMBOL? changeTablespaceOption)*)?) 
  / (READ_ONLY_SYMBOL / READ_WRITE_SYMBOL) 
  / (NOT_SYMBOL ACCESSIBLE_SYMBOL)) 
  / (RENAME_SYMBOL TO_SYMBOL identifier) 
  / alterTablespaceOptions)

alterUndoTablespace
  = UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceRef SET_SYMBOL (ACTIVE_SYMBOL / INACTIVE_SYMBOL) undoTableSpaceOptions?

undoTableSpaceOptions
  = undoTableSpaceOption (COMMA_SYMBOL? undoTableSpaceOption)*

undoTableSpaceOption
  = tsOptionEngine

alterTablespaceOptions
  = alterTablespaceOption (COMMA_SYMBOL? alterTablespaceOption)*

alterTablespaceOption
  = (INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber) 
  / tsOptionAutoextendSize 
  / tsOptionMaxSize 
  / tsOptionEngine 
  / tsOptionWait 
  / tsOptionEncryption

changeTablespaceOption
  = (INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber) 
  / tsOptionAutoextendSize 
  / tsOptionMaxSize

alterView
  = viewAlgorithm? definerClause? viewSuid? VIEW_SYMBOL viewRef viewTail

viewTail
  = columnInternalRefList? AS_SYMBOL viewSelect

viewSelect
  = queryExpressionOrParens viewCheckOption?

viewCheckOption
  = WITH_SYMBOL (CASCADED_SYMBOL / LOCAL_SYMBOL)? CHECK_SYMBOL OPTION_SYMBOL

createStatement
  = CREATE_SYMBOL (createDatabase / createTable / createFunction / createProcedure / createUdf / createLogfileGroup / createView / createTrigger / createIndex / createServer / createTablespace / createEvent / createRole / createSpatialReference / createUndoTablespace)

createDatabase
  = DATABASE_SYMBOL ifNotExists? schemaName createDatabaseOption*

createDatabaseOption
  = defaultCharset / defaultCollation / defaultEncryption

createTable
  = TEMPORARY_SYMBOL? TABLE_SYMBOL ifNotExists? tableName (((OPEN_PAR_SYMBOL tableElementList CLOSE_PAR_SYMBOL)? createTableOptions? partitionClause? duplicateAsQueryExpression?) / (LIKE_SYMBOL tableRef) / (OPEN_PAR_SYMBOL LIKE_SYMBOL tableRef CLOSE_PAR_SYMBOL))

tableElementList
  = tableElement (COMMA_SYMBOL tableElement)*

tableElement
  = columnDefinition / tableConstraintDef

duplicateAsQueryExpression
  = (REPLACE_SYMBOL / IGNORE_SYMBOL)? AS_SYMBOL? queryExpressionOrParens

queryExpressionOrParens
  = queryExpression / queryExpressionParens

createRoutine
  = CREATE_SYMBOL (createProcedure / createFunction / createUdf) SEMICOLON_SYMBOL? EOF

createProcedure
  = definerClause? PROCEDURE_SYMBOL procedureName OPEN_PAR_SYMBOL (procedureParameter (COMMA_SYMBOL procedureParameter)*)? CLOSE_PAR_SYMBOL routineCreateOption* compoundStatement

createFunction
  = definerClause? FUNCTION_SYMBOL functionName OPEN_PAR_SYMBOL (functionParameter (COMMA_SYMBOL functionParameter)*)? CLOSE_PAR_SYMBOL RETURNS_SYMBOL typeWithOptCollate routineCreateOption* compoundStatement

createUdf
  = AGGREGATE_SYMBOL? FUNCTION_SYMBOL udfName RETURNS_SYMBOL (STRING_SYMBOL / INT_SYMBOL / REAL_SYMBOL / DECIMAL_SYMBOL) SONAME_SYMBOL textLiteral

routineCreateOption
  = routineOption / (NOT_SYMBOL? DETERMINISTIC_SYMBOL)

routineAlterOptions
  = routineCreateOption+

routineOption
  = (COMMENT_SYMBOL textLiteral) 
  / (LANGUAGE_SYMBOL SQL_SYMBOL) 
  / (NO_SYMBOL SQL_SYMBOL) 
  / (CONTAINS_SYMBOL SQL_SYMBOL) 
  / (READS_SYMBOL SQL_SYMBOL DATA_SYMBOL) 
  / (MODIFIES_SYMBOL SQL_SYMBOL DATA_SYMBOL) 
  / (SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL / INVOKER_SYMBOL))

createIndex
  = onlineOption? ((UNIQUE_SYMBOL? INDEX_SYMBOL ((indexName indexTypeClause?) / indexNameAndType?) createIndexTarget indexOption*) 
  / (FULLTEXT_SYMBOL INDEX_SYMBOL indexName createIndexTarget fulltextIndexOption*) 
  / (SPATIAL_SYMBOL INDEX_SYMBOL indexName createIndexTarget spatialIndexOption*)) indexLockAndAlgorithm?

indexNameAndType
  = (indexName (USING_SYMBOL indexType)?) / (indexName TYPE_SYMBOL indexType)

createIndexTarget
  = ON_SYMBOL tableRef keyListVariants

createLogfileGroup
  = LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupName ADD_SYMBOL (UNDOFILE_SYMBOL / REDOFILE_SYMBOL) textLiteral logfileGroupOptions?

logfileGroupOptions
  = logfileGroupOption (COMMA_SYMBOL? logfileGroupOption)*

logfileGroupOption
  = tsOptionInitialSize / tsOptionUndoRedoBufferSize / tsOptionNodegroup / tsOptionEngine / tsOptionWait / tsOptionComment

createServer
  = SERVER_SYMBOL serverName FOREIGN_SYMBOL DATA_SYMBOL WRAPPER_SYMBOL textOrIdentifier serverOptions

serverOptions
  = OPTIONS_SYMBOL OPEN_PAR_SYMBOL serverOption (COMMA_SYMBOL serverOption)* CLOSE_PAR_SYMBOL

serverOption
  = (HOST_SYMBOL textLiteral) 
  / (DATABASE_SYMBOL textLiteral) 
  / (USER_SYMBOL textLiteral) 
  / (PASSWORD_SYMBOL textLiteral) 
  / (SOCKET_SYMBOL textLiteral) 
  / (OWNER_SYMBOL textLiteral) 
  / (PORT_SYMBOL ulong_number)

createTablespace
  = TABLESPACE_SYMBOL tablespaceName tsDataFileName (USE_SYMBOL LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef)? tablespaceOptions?

createUndoTablespace
  = UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceName ADD_SYMBOL tsDataFile undoTableSpaceOptions?

tsDataFileName
  = (ADD_SYMBOL tsDataFile)? / (ADD_SYMBOL tsDataFile)

tsDataFile
  = DATAFILE_SYMBOL textLiteral

tablespaceOptions
  = tablespaceOption (COMMA_SYMBOL? tablespaceOption)*

tablespaceOption
  = tsOptionInitialSize 
  / tsOptionAutoextendSize 
  / tsOptionMaxSize 
  / tsOptionExtentSize 
  / tsOptionNodegroup 
  / tsOptionEngine 
  / tsOptionWait 
  / tsOptionComment 
  / tsOptionFileblockSize 
  / tsOptionEncryption

tsOptionInitialSize
  = INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber

tsOptionUndoRedoBufferSize
  = (UNDO_BUFFER_SIZE_SYMBOL / REDO_BUFFER_SIZE_SYMBOL) EQUAL_OPERATOR? sizeNumber

tsOptionAutoextendSize
  = AUTOEXTEND_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber

tsOptionMaxSize
  = MAX_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber

tsOptionExtentSize
  = EXTENT_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber

tsOptionNodegroup
  = NODEGROUP_SYMBOL EQUAL_OPERATOR? real_ulong_number

tsOptionEngine
  = STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? engineRef

tsOptionWait
  = WAIT_SYMBOL / NO_WAIT_SYMBOL

tsOptionComment
  = COMMENT_SYMBOL EQUAL_OPERATOR? textLiteral

tsOptionFileblockSize
  = FILE_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber

tsOptionEncryption
  = ENCRYPTION_SYMBOL EQUAL_OPERATOR? textStringLiteral

createView
  = viewReplaceOrAlgorithm? definerClause? viewSuid? VIEW_SYMBOL viewName viewTail

viewReplaceOrAlgorithm
  = (OR_SYMBOL REPLACE_SYMBOL viewAlgorithm?) / viewAlgorithm

viewAlgorithm
  = ALGORITHM_SYMBOL EQUAL_OPERATOR (UNDEFINED_SYMBOL / MERGE_SYMBOL / TEMPTABLE_SYMBOL)

viewSuid
  = SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL / INVOKER_SYMBOL)

createTrigger
  = definerClause? TRIGGER_SYMBOL triggerName (BEFORE_SYMBOL / AFTER_SYMBOL) (INSERT_SYMBOL / UPDATE_SYMBOL / DELETE_SYMBOL) ON_SYMBOL tableRef FOR_SYMBOL EACH_SYMBOL ROW_SYMBOL triggerFollowsPrecedesClause? compoundStatement

triggerFollowsPrecedesClause
  = (FOLLOWS_SYMBOL / PRECEDES_SYMBOL) textOrIdentifier

createEvent
  = definerClause? EVENT_SYMBOL ifNotExists? eventName ON_SYMBOL SCHEDULE_SYMBOL schedule (ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL)? (ENABLE_SYMBOL / (DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?))? (COMMENT_SYMBOL textLiteral)? DO_SYMBOL compoundStatement

createRole
  = ROLE_SYMBOL ifNotExists? roleList

createSpatialReference
  = (OR_SYMBOL REPLACE_SYMBOL SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL real_ulonglong_number srsAttribute*) 
  / (SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL ifNotExists? real_ulonglong_number srsAttribute*)

srsAttribute
  = (NAME_SYMBOL TEXT_SYMBOL textStringNoLinebreak) 
  / (DEFINITION_SYMBOL TEXT_SYMBOL textStringNoLinebreak) 
  / (ORGANIZATION_SYMBOL textStringNoLinebreak IDENTIFIED_SYMBOL BY_SYMBOL real_ulonglong_number) 
  / (DESCRIPTION_SYMBOL TEXT_SYMBOL textStringNoLinebreak)

dropStatement
  = DROP_SYMBOL (dropDatabase / dropEvent / dropFunction / dropProcedure / dropIndex / dropLogfileGroup / dropServer / dropTable / dropTableSpace / dropTrigger / dropView / dropRole / dropSpatialReference / dropUndoTablespace)

dropDatabase
  = DATABASE_SYMBOL ifExists? schemaRef

dropEvent
  = EVENT_SYMBOL ifExists? eventRef

dropFunction
  = FUNCTION_SYMBOL ifExists? functionRef

dropProcedure
  = PROCEDURE_SYMBOL ifExists? procedureRef

dropIndex
  = onlineOption? INDEX_SYMBOL indexRef ON_SYMBOL tableRef indexLockAndAlgorithm?

dropLogfileGroup
  = LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef (dropLogfileGroupOption (COMMA_SYMBOL? dropLogfileGroupOption)*)?

dropLogfileGroupOption
  = tsOptionWait / tsOptionEngine

dropServer
  = SERVER_SYMBOL ifExists? serverRef

dropTable
  = TEMPORARY_SYMBOL? (TABLE_SYMBOL / TABLES_SYMBOL) ifExists? tableRefList (RESTRICT_SYMBOL / CASCADE_SYMBOL)?

dropTableSpace
  = TABLESPACE_SYMBOL tablespaceRef (dropLogfileGroupOption (COMMA_SYMBOL? dropLogfileGroupOption)*)?

dropTrigger
  = TRIGGER_SYMBOL ifExists? triggerRef

dropView
  = VIEW_SYMBOL ifExists? viewRefList (RESTRICT_SYMBOL / CASCADE_SYMBOL)?

dropRole
  = ROLE_SYMBOL ifExists? roleList

dropSpatialReference
  = SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL ifExists? real_ulonglong_number

dropUndoTablespace
  = UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceRef undoTableSpaceOptions?

renameTableStatement
  = RENAME_SYMBOL (TABLE_SYMBOL / TABLES_SYMBOL) renamePair (COMMA_SYMBOL renamePair)*

renamePair
  = tableRef TO_SYMBOL tableName

truncateTableStatement
  = TRUNCATE_SYMBOL TABLE_SYMBOL? tableRef

importStatement
  = IMPORT_SYMBOL TABLE_SYMBOL FROM_SYMBOL textStringLiteralList

callStatement
  = CALL_SYMBOL procedureRef (OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL)?

deleteStatement
  = withClause? DELETE_SYMBOL deleteStatementOption* ((FROM_SYMBOL ((tableAliasRefList USING_SYMBOL tableReferenceList whereClause?) / (tableRef tableAlias? partitionDelete? whereClause? orderClause? simpleLimitClause?))) / (tableAliasRefList FROM_SYMBOL tableReferenceList whereClause?))

partitionDelete
  = PARTITION_SYMBOL OPEN_PAR_SYMBOL identifierList CLOSE_PAR_SYMBOL

deleteStatementOption
  = QUICK_SYMBOL / LOW_PRIORITY_SYMBOL / QUICK_SYMBOL / IGNORE_SYMBOL

doStatement
  = DO_SYMBOL (exprList / selectItemList)

handlerStatement
  = HANDLER_SYMBOL ((tableRef OPEN_SYMBOL tableAlias?) / (identifier (CLOSE_SYMBOL / (READ_SYMBOL handlerReadOrScan whereClause? limitClause?))))

handlerReadOrScan
  = (FIRST_SYMBOL / NEXT_SYMBOL) 
  / (identifier ((FIRST_SYMBOL / NEXT_SYMBOL / PREV_SYMBOL / LAST_SYMBOL) 
  / ((EQUAL_OPERATOR / LESS_THAN_OPERATOR / GREATER_THAN_OPERATOR / LESS_OR_EQUAL_OPERATOR / GREATER_OR_EQUAL_OPERATOR) OPEN_PAR_SYMBOL values CLOSE_PAR_SYMBOL)))

insertStatement
  = INSERT_SYMBOL insertLockOption? IGNORE_SYMBOL? INTO_SYMBOL? tableRef usePartition? ((insertFromConstructor valuesReference?) / (SET_SYMBOL updateList valuesReference?) / insertQueryExpression)

insertLockOption
  = LOW_PRIORITY_SYMBOL / DELAYED_SYMBOL / HIGH_PRIORITY_SYMBOL

insertFromConstructor
  = (OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL)? insertValues

fields
  = insertIdentifier (COMMA_SYMBOL insertIdentifier)*

insertValues
  = (VALUES_SYMBOL / VALUE_SYMBOL) valueList

insertQueryExpression
  = queryExpressionOrParens / (OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL queryExpressionOrParens)

valueList
  = OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL (COMMA_SYMBOL OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL)*

values
  = (expr / DEFAULT_SYMBOL) (COMMA_SYMBOL (expr / DEFAULT_SYMBOL))*

valuesReference
  = AS_SYMBOL identifier columnInternalRefList?

insertUpdateList
  = ON_SYMBOL DUPLICATE_SYMBOL KEY_SYMBOL UPDATE_SYMBOL updateList

loadStatement
  = LOAD_SYMBOL dataOrXml (LOW_PRIORITY_SYMBOL / CONCURRENT_SYMBOL)? LOCAL_SYMBOL? INFILE_SYMBOL textLiteral (REPLACE_SYMBOL / IGNORE_SYMBOL)? INTO_SYMBOL TABLE_SYMBOL tableRef usePartition? charsetClause? xmlRowsIdentifiedBy? fieldsClause? linesClause? loadDataFileTail

dataOrXml
  = DATA_SYMBOL / XML_SYMBOL

xmlRowsIdentifiedBy
  = ROWS_SYMBOL IDENTIFIED_SYMBOL BY_SYMBOL textString

loadDataFileTail
  = (IGNORE_SYMBOL INT_NUMBER (LINES_SYMBOL / ROWS_SYMBOL))? loadDataFileTargetList? (SET_SYMBOL updateList)?

loadDataFileTargetList
  = OPEN_PAR_SYMBOL fieldOrVariableList? CLOSE_PAR_SYMBOL

fieldOrVariableList
  = (columnRef / userVariable) (COMMA_SYMBOL (columnRef / userVariable))*

replaceStatement
  = REPLACE_SYMBOL (LOW_PRIORITY_SYMBOL / DELAYED_SYMBOL)? INTO_SYMBOL? tableRef usePartition? (insertFromConstructor / (SET_SYMBOL updateList) / insertQueryExpression)

selectStatement
  = (queryExpression lockingClauseList?) / queryExpressionParens / selectStatementWithInto

selectStatementWithInto
  = (OPEN_PAR_SYMBOL selectStatementWithInto CLOSE_PAR_SYMBOL) / (queryExpression intoClause lockingClauseList?) / (lockingClauseList intoClause)

queryExpression
  = withClause? ((queryExpressionBody orderClause? limitClause?) / (queryExpressionParens orderClause? limitClause?)) procedureAnalyseClause?

queryExpressionBody
  = (queryPrimary / (queryExpressionParens UNION_SYMBOL unionOption? (queryPrimary / queryExpressionParens))) (UNION_SYMBOL unionOption? (queryPrimary / queryExpressionParens))*

queryExpressionParens
  = OPEN_PAR_SYMBOL (queryExpressionParens / (queryExpression lockingClauseList?)) CLOSE_PAR_SYMBOL

queryPrimary
  = querySpecification / tableValueConstructor / explicitTable

querySpecification
  = SELECT_SYMBOL selectOption* selectItemList intoClause? fromClause? whereClause? groupByClause? havingClause? windowClause?

subquery
  = queryExpressionParens

querySpecOption
  = ALL_SYMBOL / DISTINCT_SYMBOL / STRAIGHT_JOIN_SYMBOL / HIGH_PRIORITY_SYMBOL / SQL_SMALL_RESULT_SYMBOL / SQL_BIG_RESULT_SYMBOL / SQL_BUFFER_RESULT_SYMBOL / SQL_CALC_FOUND_ROWS_SYMBOL

limitClause
  = LIMIT_SYMBOL limitOptions

simpleLimitClause
  = LIMIT_SYMBOL limitOption

limitOptions
  = limitOption ((COMMA_SYMBOL / OFFSET_SYMBOL) limitOption)?

limitOption
  = identifier / (PARAM_MARKER / ULONGLONG_NUMBER / LONG_NUMBER / INT_NUMBER)

intoClause
  = INTO_SYMBOL ((OUTFILE_SYMBOL textStringLiteral charsetClause? fieldsClause? linesClause?) 
  / (DUMPFILE_SYMBOL textStringLiteral) 
  / ((textOrIdentifier / userVariable) (COMMA_SYMBOL (textOrIdentifier / userVariable))*))

procedureAnalyseClause
  = PROCEDURE_SYMBOL ANALYSE_SYMBOL OPEN_PAR_SYMBOL (INT_NUMBER (COMMA_SYMBOL INT_NUMBER)?)? CLOSE_PAR_SYMBOL

havingClause
  = HAVING_SYMBOL expr

windowClause
  = WINDOW_SYMBOL windowDefinition (COMMA_SYMBOL windowDefinition)*

windowDefinition
  = windowName AS_SYMBOL windowSpec

windowSpec
  = OPEN_PAR_SYMBOL windowSpecDetails CLOSE_PAR_SYMBOL

windowSpecDetails
  = windowName? (PARTITION_SYMBOL BY_SYMBOL orderList)? orderClause? windowFrameClause?

windowFrameClause
  = windowFrameUnits windowFrameExtent windowFrameExclusion?

windowFrameUnits
  = ROWS_SYMBOL / RANGE_SYMBOL / GROUPS_SYMBOL

windowFrameExtent
  = windowFrameStart / windowFrameBetween

windowFrameStart
  = (UNBOUNDED_SYMBOL PRECEDING_SYMBOL) 
  / (ulonglong_number PRECEDING_SYMBOL) 
  / (PARAM_MARKER PRECEDING_SYMBOL) 
  / (INTERVAL_SYMBOL expr interval PRECEDING_SYMBOL) 
  / (CURRENT_SYMBOL ROW_SYMBOL)

windowFrameBetween
  = BETWEEN_SYMBOL windowFrameBound AND_SYMBOL windowFrameBound

windowFrameBound
  = windowFrameStart 
  / (UNBOUNDED_SYMBOL FOLLOWING_SYMBOL) 
  / (ulonglong_number FOLLOWING_SYMBOL) 
  / (PARAM_MARKER FOLLOWING_SYMBOL) 
  / (INTERVAL_SYMBOL expr interval FOLLOWING_SYMBOL)

windowFrameExclusion
  = EXCLUDE_SYMBOL ((CURRENT_SYMBOL ROW_SYMBOL) / GROUP_SYMBOL / TIES_SYMBOL / (NO_SYMBOL OTHERS_SYMBOL))

withClause
  = WITH_SYMBOL RECURSIVE_SYMBOL? commonTableExpression (COMMA_SYMBOL commonTableExpression)*

commonTableExpression
  = identifier columnInternalRefList? AS_SYMBOL subquery

groupByClause
  = GROUP_SYMBOL BY_SYMBOL orderList olapOption?

olapOption
  = (WITH_SYMBOL ROLLUP_SYMBOL) / (WITH_SYMBOL CUBE_SYMBOL)

orderClause
  = ORDER_SYMBOL BY_SYMBOL orderList

direction
  = ASC_SYMBOL / DESC_SYMBOL

fromClause
  = FROM_SYMBOL (DUAL_SYMBOL / tableReferenceList)

tableReferenceList
  = tableReference (COMMA_SYMBOL tableReference)*

tableValueConstructor
  = VALUES_SYMBOL rowValueExplicit (COMMA_SYMBOL rowValueExplicit)*

explicitTable
  = TABLE_SYMBOL tableRef

rowValueExplicit
  = ROW_SYMBOL OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL

selectOption
  = querySpecOption 
  / SQL_NO_CACHE_SYMBOL 
  / SQL_CACHE_SYMBOL 
  / (MAX_STATEMENT_TIME_SYMBOL EQUAL_OPERATOR real_ulong_number)

