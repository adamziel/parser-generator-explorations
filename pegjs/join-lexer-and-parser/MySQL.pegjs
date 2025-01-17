{
  const serverInfo = {
    ANSI_QUOTES: 1,
    isSqlModeActive() {
      return false;
    },
    getServerVersion() {
      return 80000;
    }
  };
  const serverVersion = serverInfo.getServerVersion();
}

Start
  = query

query
  = EOF
  / (simpleStatement / beginWork) (SEMICOLON_SYMBOL EOF? / EOF)

simpleStatement
  = // DDL
    alterStatement
  / createStatement
  / dropStatement
  / renameTableStatement
  / truncateTableStatement
  / &{serverVersion >= 80000} importStatement
  // DML
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
  // Data Directory
  / &{serverVersion >= 80000} cloneStatement
  // Database administration
  / accountManagementStatement
  / tableAdministrationStatement
  / installUninstallStatment
  / setStatement // SET PASSWORD is handled in accountManagementStatement.
  / showStatement
  / &{serverVersion >= 80000} resourceGroupManagement
  / otherAdministrativeStatement
  // MySQL utilitity statements
  / utilityStatement
  / &{serverVersion >= 50604} getDiagnostics
  / signalStatement
  / resignalStatement

//----------------- DDL statements -------------------------------------------------------------------------------------

alterStatement
  = ALTER_SYMBOL
    ( alterTable
    / alterDatabase
    / PROCEDURE_SYMBOL procedureRef routineAlterOptions?
    / FUNCTION_SYMBOL functionRef routineAlterOptions?
    / alterView
    / alterEvent
    / alterTablespace
    / &{serverVersion >= 80014} alterUndoTablespace
    / alterLogfileGroup
    / alterServer
    // ALTER USER is part of the user management rule.
    / &{serverVersion >= 50713} INSTANCE_SYMBOL ROTATE_SYMBOL textOrIdentifier MASTER_SYMBOL KEY_SYMBOL
    )

alterDatabase
  = DATABASE_SYMBOL schemaRef
    ( createDatabaseOption+
    / &{serverVersion < 80000} UPGRADE_SYMBOL DATA_SYMBOL DIRECTORY_SYMBOL NAME_SYMBOL
    )

alterEvent
  = definerClause?
    EVENT_SYMBOL eventRef
    (ON_SYMBOL SCHEDULE_SYMBOL schedule)?
    (ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL)?
    (RENAME_SYMBOL TO_SYMBOL identifier)?
    (ENABLE_SYMBOL / DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?)?
    (COMMENT_SYMBOL textLiteral)?
    (DO_SYMBOL compoundStatement)?

alterLogfileGroup
  = LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef ADD_SYMBOL UNDOFILE_SYMBOL textLiteral alterLogfileGroupOptions?

alterLogfileGroupOptions
  = alterLogfileGroupOption (COMMA_SYMBOL? alterLogfileGroupOption)*

alterLogfileGroupOption
  = tsOptionInitialSize
  / tsOptionEngine
  / tsOptionWait

alterServer
  = SERVER_SYMBOL serverRef serverOptions

alterTable
  = onlineOption? (&{serverVersion < 50700} IGNORE_SYMBOL)? TABLE_SYMBOL tableRef alterTableActions?

alterTableActions
  = alterCommandList (partitionClause / removePartitioning)?
  / partitionClause
  / removePartitioning
  / (alterCommandsModifierList COMMA_SYMBOL)? standaloneAlterCommands

alterCommandList
  = alterCommandsModifierList
  / (alterCommandsModifierList COMMA_SYMBOL)? alterList

alterCommandsModifierList
  = alterCommandsModifier (COMMA_SYMBOL alterCommandsModifier)*

standaloneAlterCommands
  = DISCARD_SYMBOL TABLESPACE_SYMBOL
  / IMPORT_SYMBOL TABLESPACE_SYMBOL
  / alterPartition
  / &{serverVersion >= 80014} (SECONDARY_LOAD_SYMBOL / SECONDARY_UNLOAD_SYMBOL)

alterPartition
  = ADD_SYMBOL PARTITION_SYMBOL noWriteToBinLog?
    ( partitionDefinitions
    / PARTITIONS_SYMBOL real_ulong_number
    )
  / DROP_SYMBOL PARTITION_SYMBOL identifierList
  / REBUILD_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList
  // yes, twice "no write to bin log".
  / OPTIMIZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList noWriteToBinLog?
  / ANALYZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList
  / CHECK_SYMBOL PARTITION_SYMBOL allOrPartitionNameList checkOption*
  / REPAIR_SYMBOL PARTITION_SYMBOL noWriteToBinLog? allOrPartitionNameList repairType*
  / COALESCE_SYMBOL PARTITION_SYMBOL noWriteToBinLog? real_ulong_number
  / TRUNCATE_SYMBOL PARTITION_SYMBOL allOrPartitionNameList
  / REORGANIZE_SYMBOL PARTITION_SYMBOL noWriteToBinLog?
    (identifierList INTO_SYMBOL partitionDefinitions)?
  / EXCHANGE_SYMBOL PARTITION_SYMBOL identifier WITH_SYMBOL TABLE_SYMBOL tableRef withValidation?
  / &{serverVersion >= 50704} DISCARD_SYMBOL PARTITION_SYMBOL allOrPartitionNameList TABLESPACE_SYMBOL
  / &{serverVersion >= 50704} IMPORT_SYMBOL PARTITION_SYMBOL allOrPartitionNameList TABLESPACE_SYMBOL

alterList
  = (alterListItem / createTableOptionsSpaceSeparated)
    (COMMA_SYMBOL (alterListItem / alterCommandsModifier / createTableOptionsSpaceSeparated))*

alterCommandsModifier
  = alterAlgorithmOption
  / alterLockOption
  / withValidation

alterListItem
  = ADD_SYMBOL COLUMN_SYMBOL?
    ( identifier fieldDefinition checkOrReferences? place?
    / OPEN_PAR_SYMBOL tableElementList CLOSE_PAR_SYMBOL
    )
  / ADD_SYMBOL tableConstraintDef
  / CHANGE_SYMBOL COLUMN_SYMBOL? columnInternalRef identifier fieldDefinition place?
  / MODIFY_SYMBOL COLUMN_SYMBOL? columnInternalRef fieldDefinition place?
  / DROP_SYMBOL
    ( COLUMN_SYMBOL? columnInternalRef restrict?
    / FOREIGN_SYMBOL KEY_SYMBOL
      ( // This part is no longer optional starting with 5.7.
        &{serverVersion >= 50700} columnInternalRef
      / &{serverVersion < 50700} columnInternalRef?
      )
    / PRIMARY_SYMBOL KEY_SYMBOL
    / keyOrIndex indexRef
    / &{serverVersion >= 80017} CHECK_SYMBOL identifier
    / &{serverVersion >= 80019} CONSTRAINT_SYMBOL identifier
    )
  / DISABLE_SYMBOL KEYS_SYMBOL
  / ENABLE_SYMBOL KEYS_SYMBOL
  / ALTER_SYMBOL COLUMN_SYMBOL? columnInternalRef
    ( SET_SYMBOL DEFAULT_SYMBOL
      ( &{serverVersion >= 80014} exprWithParentheses
      / signedLiteral
      )
    / DROP_SYMBOL DEFAULT_SYMBOL
    )
  / &{serverVersion >= 80000} ALTER_SYMBOL INDEX_SYMBOL indexRef visibility
  / &{serverVersion >= 80017} ALTER_SYMBOL CHECK_SYMBOL identifier constraintEnforcement
  / &{serverVersion >= 80019} ALTER_SYMBOL CONSTRAINT_SYMBOL identifier constraintEnforcement
  / &{serverVersion >= 80000} RENAME_SYMBOL COLUMN_SYMBOL columnInternalRef TO_SYMBOL identifier
  / RENAME_SYMBOL (TO_SYMBOL / AS_SYMBOL)? tableName
  / &{serverVersion >= 50700} RENAME_SYMBOL keyOrIndex indexRef TO_SYMBOL indexName
  / CONVERT_SYMBOL TO_SYMBOL charset
    ( &{serverVersion >= 80014} DEFAULT_SYMBOL
    / charsetName
    )
    collate?
  / FORCE_SYMBOL
  / ORDER_SYMBOL BY_SYMBOL alterOrderList
  / &{serverVersion >= 50708 && serverVersion < 80000} UPGRADE_SYMBOL PARTITIONING_SYMBOL

place
  = AFTER_SYMBOL identifier
  / FIRST_SYMBOL

restrict
  = RESTRICT_SYMBOL
  / CASCADE_SYMBOL

alterOrderList
  = identifier direction? (COMMA_SYMBOL identifier direction?)*

alterAlgorithmOption
  = ALGORITHM_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL / identifier)

alterLockOption
  = LOCK_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL / identifier)

indexLockAndAlgorithm
  = alterAlgorithmOption alterLockOption?
  / alterLockOption alterAlgorithmOption?

withValidation
  = &{serverVersion >= 50706} (WITH_SYMBOL / WITHOUT_SYMBOL) VALIDATION_SYMBOL

removePartitioning
  = REMOVE_SYMBOL PARTITIONING_SYMBOL

allOrPartitionNameList
  = ALL_SYMBOL
  / identifierList

alterTablespace
  = TABLESPACE_SYMBOL tablespaceRef
    ( (ADD_SYMBOL / DROP_SYMBOL) DATAFILE_SYMBOL textLiteral alterTablespaceOptions?
    / &{serverVersion < 80000}
      ( CHANGE_SYMBOL DATAFILE_SYMBOL textLiteral
        (changeTablespaceOption (COMMA_SYMBOL? changeTablespaceOption)*)?
      / (READ_ONLY_SYMBOL / READ_WRITE_SYMBOL)
      / NOT_SYMBOL ACCESSIBLE_SYMBOL
      )
    / RENAME_SYMBOL TO_SYMBOL identifier
    / &{serverVersion >= 80014} alterTablespaceOptions
    )

alterUndoTablespace
  = UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceRef SET_SYMBOL
    ( ACTIVE_SYMBOL
    / INACTIVE_SYMBOL
    )
    undoTableSpaceOptions?

undoTableSpaceOptions
  = undoTableSpaceOption (COMMA_SYMBOL? undoTableSpaceOption)*

undoTableSpaceOption
  = tsOptionEngine

alterTablespaceOptions
  = alterTablespaceOption (COMMA_SYMBOL? alterTablespaceOption)*

alterTablespaceOption
  = INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
  / tsOptionAutoextendSize
  / tsOptionMaxSize
  / tsOptionEngine
  / tsOptionWait
  / tsOptionEncryption

changeTablespaceOption
  = INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber
  / tsOptionAutoextendSize
  / tsOptionMaxSize

alterView
  = viewAlgorithm? definerClause? viewSuid? VIEW_SYMBOL viewRef viewTail

// This is not the full view_tail from sql_yacc.yy as we have either a view name or a view reference,
// depending on whether we come from createView or alterView. Everything until this difference is duplicated in those rules.
viewTail
  = columnInternalRefList? AS_SYMBOL viewSelect

viewSelect
  = queryExpressionOrParens viewCheckOption?

viewCheckOption
  = WITH_SYMBOL (CASCADED_SYMBOL / LOCAL_SYMBOL)? CHECK_SYMBOL OPTION_SYMBOL

//----------------------------------------------------------------------------------------------------------------------

createStatement
  = CREATE_SYMBOL
    ( createDatabase
    / createTable
    / createFunction
    / createProcedure
    / createUdf
    / createLogfileGroup
    / createView
    / createTrigger
    / createIndex
    / createServer
    / createTablespace
    / createEvent
    / &{serverVersion >= 80000} createRole
    / &{serverVersion >= 80011} createSpatialReference
    / &{serverVersion >= 80014} createUndoTablespace
    )

createDatabase
  = DATABASE_SYMBOL ifNotExists? schemaName createDatabaseOption*

createDatabaseOption
  = defaultCharset
  / defaultCollation
  / &{serverVersion >= 80016} defaultEncryption

createTable
  = TEMPORARY_SYMBOL? TABLE_SYMBOL ifNotExists? tableName
    ( (OPEN_PAR_SYMBOL tableElementList CLOSE_PAR_SYMBOL)?
      createTableOptions? partitionClause? duplicateAsQueryExpression?
    / LIKE_SYMBOL tableRef
    / OPEN_PAR_SYMBOL LIKE_SYMBOL tableRef CLOSE_PAR_SYMBOL
    )

tableElementList
  = tableElement (COMMA_SYMBOL tableElement)*

tableElement
  = columnDefinition
  / tableConstraintDef

duplicateAsQueryExpression
  = (REPLACE_SYMBOL / IGNORE_SYMBOL)? AS_SYMBOL? queryExpressionOrParens

queryExpressionOrParens
  = queryExpression
  / queryExpressionParens

createRoutine // Rule for external use only.
  = CREATE_SYMBOL (createProcedure / createFunction / createUdf) SEMICOLON_SYMBOL? EOF

createProcedure
  = definerClause?
    PROCEDURE_SYMBOL procedureName
    OPEN_PAR_SYMBOL (procedureParameter (COMMA_SYMBOL procedureParameter)*)?
    CLOSE_PAR_SYMBOL routineCreateOption* compoundStatement

createFunction
  = definerClause?
    FUNCTION_SYMBOL functionName
    OPEN_PAR_SYMBOL (functionParameter (COMMA_SYMBOL functionParameter)*)?
    CLOSE_PAR_SYMBOL RETURNS_SYMBOL typeWithOptCollate routineCreateOption* compoundStatement

createUdf
  = AGGREGATE_SYMBOL? FUNCTION_SYMBOL udfName RETURNS_SYMBOL
    ( STRING_SYMBOL
      / INT_SYMBOL
      / REAL_SYMBOL
      / DECIMAL_SYMBOL
      )
    SONAME_SYMBOL textLiteral

routineCreateOption
  = routineOption
  / NOT_SYMBOL? DETERMINISTIC_SYMBOL

routineAlterOptions
  = routineCreateOption+

routineOption
  = COMMENT_SYMBOL textLiteral
  / LANGUAGE_SYMBOL SQL_SYMBOL
  / NO_SYMBOL SQL_SYMBOL
  / CONTAINS_SYMBOL SQL_SYMBOL
  / READS_SYMBOL SQL_SYMBOL DATA_SYMBOL
  / MODIFIES_SYMBOL SQL_SYMBOL DATA_SYMBOL
  / SQL_SYMBOL SECURITY_SYMBOL ( DEFINER_SYMBOL
      / INVOKER_SYMBOL
    )

createIndex
  = onlineOption?
    ( UNIQUE_SYMBOL?
      INDEX_SYMBOL
      ( &{serverVersion >= 80014} indexName indexTypeClause?
      / indexNameAndType?
      )
      createIndexTarget indexOption*
    / FULLTEXT_SYMBOL INDEX_SYMBOL indexName createIndexTarget fulltextIndexOption*
    / SPATIAL_SYMBOL INDEX_SYMBOL indexName createIndexTarget spatialIndexOption*
    )
    indexLockAndAlgorithm?

/*
  The syntax for defining an index is:

    ... INDEX [index_name] [USING|TYPE] <index_type> ...

  The problem is that whereas USING is a reserved word, TYPE is not. We can
  still handle it if an index name is supplied, i.e.:

    ... INDEX type TYPE <index_type> ...

  here the index's name is unmbiguously 'type', but for this:

    ... INDEX TYPE <index_type> ...

  it's impossible to know what this actually mean - is 'type' the name or the
  type? For this reason we accept the TYPE syntax only if a name is supplied.
*/
indexNameAndType
  = indexName (USING_SYMBOL indexType)?
  / indexName TYPE_SYMBOL indexType

createIndexTarget
  = ON_SYMBOL tableRef keyListVariants

createLogfileGroup
  = LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupName ADD_SYMBOL
    ( UNDOFILE_SYMBOL
    / REDOFILE_SYMBOL // No longer used from 8.0 onwards. Taken out by lexer.
    )
    textLiteral logfileGroupOptions?

logfileGroupOptions
  = logfileGroupOption (COMMA_SYMBOL? logfileGroupOption)*

logfileGroupOption
  = tsOptionInitialSize
  / tsOptionUndoRedoBufferSize
  / tsOptionNodegroup
  / tsOptionEngine
  / tsOptionWait
  / tsOptionComment

createServer
  = SERVER_SYMBOL serverName FOREIGN_SYMBOL DATA_SYMBOL WRAPPER_SYMBOL textOrIdentifier serverOptions

serverOptions
  = OPTIONS_SYMBOL OPEN_PAR_SYMBOL serverOption (COMMA_SYMBOL serverOption)* CLOSE_PAR_SYMBOL

// Options for CREATE/ALTER SERVER, used for the federated storage engine.
serverOption
  = HOST_SYMBOL textLiteral
  / DATABASE_SYMBOL textLiteral
  / USER_SYMBOL textLiteral
  / PASSWORD_SYMBOL textLiteral
  / SOCKET_SYMBOL textLiteral
  / OWNER_SYMBOL textLiteral
  / PORT_SYMBOL ulong_number

createTablespace
  = TABLESPACE_SYMBOL tablespaceName tsDataFileName
    (USE_SYMBOL LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef)?
    tablespaceOptions?

createUndoTablespace
  = UNDO_SYMBOL TABLESPACE_SYMBOL tablespaceName ADD_SYMBOL tsDataFile undoTableSpaceOptions?

tsDataFileName
  = &{serverVersion >= 80014} (ADD_SYMBOL tsDataFile)?
  / ADD_SYMBOL tsDataFile

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
  / &{serverVersion >= 50707} tsOptionFileblockSize
  / &{serverVersion >= 80014} tsOptionEncryption

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
  = WAIT_SYMBOL
  / NO_WAIT_SYMBOL

tsOptionComment
  = COMMENT_SYMBOL EQUAL_OPERATOR? textLiteral

tsOptionFileblockSize
  = FILE_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? sizeNumber

tsOptionEncryption
  = ENCRYPTION_SYMBOL EQUAL_OPERATOR? textStringLiteral

createView
  = viewReplaceOrAlgorithm? definerClause? viewSuid? VIEW_SYMBOL viewName viewTail

viewReplaceOrAlgorithm
  = OR_SYMBOL REPLACE_SYMBOL viewAlgorithm?
  / viewAlgorithm

viewAlgorithm
  = ALGORITHM_SYMBOL EQUAL_OPERATOR
    algorithm
    = ( UNDEFINED_SYMBOL
      / MERGE_SYMBOL
      / TEMPTABLE_SYMBOL
      )

viewSuid
  = SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL / INVOKER_SYMBOL)

createTrigger
  = definerClause?
    TRIGGER_SYMBOL triggerName
    timing = (BEFORE_SYMBOL / AFTER_SYMBOL)
    event
    = ( INSERT_SYMBOL
      / UPDATE_SYMBOL
      / DELETE_SYMBOL
      )
    ON_SYMBOL tableRef
    FOR_SYMBOL EACH_SYMBOL ROW_SYMBOL triggerFollowsPrecedesClause?
    compoundStatement

triggerFollowsPrecedesClause
  = &{serverVersion >= 50700}
    ordering = (FOLLOWS_SYMBOL / PRECEDES_SYMBOL) textOrIdentifier // not a trigger reference!

createEvent
  = definerClause?
    EVENT_SYMBOL ifNotExists? eventName
    ON_SYMBOL SCHEDULE_SYMBOL schedule
    (ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL)?
    (ENABLE_SYMBOL / DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?)?
    (COMMENT_SYMBOL textLiteral)?
    DO_SYMBOL compoundStatement

createRole
  = // The server grammar has a clear_privileges rule here, which is only used to clear internal state.
    ROLE_SYMBOL ifNotExists? roleList

createSpatialReference
  = OR_SYMBOL REPLACE_SYMBOL SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL
    real_ulonglong_number srsAttribute*
  / SPATIAL_SYMBOL REFERENCE_SYMBOL SYSTEM_SYMBOL ifNotExists?
    real_ulonglong_number srsAttribute*

srsAttribute
  = NAME_SYMBOL TEXT_SYMBOL textStringNoLinebreak
  / DEFINITION_SYMBOL TEXT_SYMBOL textStringNoLinebreak
  / ORGANIZATION_SYMBOL
    textStringNoLinebreak IDENTIFIED_SYMBOL BY_SYMBOL real_ulonglong_number
  / DESCRIPTION_SYMBOL TEXT_SYMBOL textStringNoLinebreak

//----------------------------------------------------------------------------------------------------------------------

dropStatement
  = DROP_SYMBOL
    ( dropDatabase
    / dropEvent
    / dropFunction
    / dropProcedure
    / dropIndex
    / dropLogfileGroup
    / dropServer
    / dropTable
    / dropTableSpace
    / dropTrigger
    / dropView
    / &{serverVersion >= 80000} dropRole
    / &{serverVersion >= 80011} dropSpatialReference
    / &{serverVersion >= 80014} dropUndoTablespace
    )

dropDatabase
  = DATABASE_SYMBOL ifExists? schemaRef

dropEvent
  = EVENT_SYMBOL ifExists? eventRef

dropFunction
  = FUNCTION_SYMBOL ifExists? functionRef // Including UDFs.

dropProcedure
  = PROCEDURE_SYMBOL ifExists? procedureRef

dropIndex
  = onlineOption? INDEX_SYMBOL indexRef ON_SYMBOL tableRef indexLockAndAlgorithm?

dropLogfileGroup
  = LOGFILE_SYMBOL GROUP_SYMBOL logfileGroupRef
    (dropLogfileGroupOption (COMMA_SYMBOL? dropLogfileGroupOption)*)?

dropLogfileGroupOption
  = tsOptionWait
  / tsOptionEngine

dropServer
  = SERVER_SYMBOL ifExists? serverRef

dropTable
  = TEMPORARY_SYMBOL?
    (TABLE_SYMBOL / TABLES_SYMBOL)
    ifExists? tableRefList
    ( RESTRICT_SYMBOL
    / CASCADE_SYMBOL
    )?

dropTableSpace
  = TABLESPACE_SYMBOL tablespaceRef
    (dropLogfileGroupOption (COMMA_SYMBOL? dropLogfileGroupOption)*)?

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

//----------------------------------------------------------------------------------------------------------------------

renameTableStatement
  = RENAME_SYMBOL (TABLE_SYMBOL / TABLES_SYMBOL) renamePair (COMMA_SYMBOL renamePair)*

renamePair
  = tableRef TO_SYMBOL tableName

//----------------------------------------------------------------------------------------------------------------------

truncateTableStatement
  = TRUNCATE_SYMBOL TABLE_SYMBOL? tableRef

//----------------------------------------------------------------------------------------------------------------------

importStatement
  = IMPORT_SYMBOL TABLE_SYMBOL FROM_SYMBOL textStringLiteralList

//--------------- DML statements ---------------------------------------------------------------------------------------

callStatement
  = CALL_SYMBOL procedureRef (OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL)?

deleteStatement
  = (&{serverVersion >= 80000} withClause)?
    DELETE_SYMBOL deleteStatementOption*
    ( FROM_SYMBOL
      ( tableAliasRefList USING_SYMBOL tableReferenceList whereClause?       // Multi table variant 1.
      / tableRef (&{serverVersion >= 80017} tableAlias)? partitionDelete?
        whereClause? orderClause? simpleLimitClause?                     // Single table delete.
      )
    / tableAliasRefList FROM_SYMBOL tableReferenceList whereClause?          // Multi table variant 2.
    )

partitionDelete
  = &{serverVersion >= 50602} PARTITION_SYMBOL OPEN_PAR_SYMBOL identifierList CLOSE_PAR_SYMBOL

deleteStatementOption // opt_delete_option in sql_yacc.yy, but the name collides with another rule (delete_options).
  = QUICK_SYMBOL
  / LOW_PRIORITY_SYMBOL
  / QUICK_SYMBOL
  / IGNORE_SYMBOL

doStatement
  = DO_SYMBOL
    ( &{serverVersion < 50709} exprList
    / &{serverVersion >= 50709} selectItemList
    )

handlerStatement
  = HANDLER_SYMBOL
    ( tableRef OPEN_SYMBOL tableAlias?
    / identifier
      ( CLOSE_SYMBOL
      / READ_SYMBOL handlerReadOrScan whereClause? limitClause?
      )
    )

handlerReadOrScan
  = (FIRST_SYMBOL / NEXT_SYMBOL) // Scan function.
  / identifier
    ( // The rkey part.
      (FIRST_SYMBOL / NEXT_SYMBOL / PREV_SYMBOL / LAST_SYMBOL)
    / ( EQUAL_OPERATOR
      / LESS_THAN_OPERATOR
      / GREATER_THAN_OPERATOR
      / LESS_OR_EQUAL_OPERATOR
      / GREATER_OR_EQUAL_OPERATOR
      )
      OPEN_PAR_SYMBOL values CLOSE_PAR_SYMBOL
    )

//----------------------------------------------------------------------------------------------------------------------

insertStatement
  = INSERT_SYMBOL
    insertLockOption? IGNORE_SYMBOL? INTO_SYMBOL? tableRef
    usePartition?
    ( insertFromConstructor (&{ serverVersion >= 80018} valuesReference)?
    / SET_SYMBOL updateList (&{ serverVersion >= 80018} valuesReference)?
    / insertQueryExpression
    )
    insertUpdateList?

insertLockOption
  = LOW_PRIORITY_SYMBOL
  / DELAYED_SYMBOL // Only allowed if no select is used. Check in the semantic phase.
  / HIGH_PRIORITY_SYMBOL

insertFromConstructor
  = (OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL)? insertValues

fields
  = insertIdentifier (COMMA_SYMBOL insertIdentifier)*

insertValues
  = (VALUES_SYMBOL / VALUE_SYMBOL) valueList

insertQueryExpression
  = queryExpressionOrParens
  / OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL queryExpressionOrParens

valueList
  = OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL
    (COMMA_SYMBOL OPEN_PAR_SYMBOL values? CLOSE_PAR_SYMBOL)*

values
  = (expr / DEFAULT_SYMBOL) (COMMA_SYMBOL (expr / DEFAULT_SYMBOL))*

valuesReference
  = AS_SYMBOL identifier columnInternalRefList?

insertUpdateList
  = ON_SYMBOL DUPLICATE_SYMBOL KEY_SYMBOL UPDATE_SYMBOL updateList

//----------------------------------------------------------------------------------------------------------------------

loadStatement
  = LOAD_SYMBOL
    dataOrXml (LOW_PRIORITY_SYMBOL / CONCURRENT_SYMBOL)? LOCAL_SYMBOL?
    INFILE_SYMBOL textLiteral
    ( REPLACE_SYMBOL
    / IGNORE_SYMBOL
    )?
    INTO_SYMBOL TABLE_SYMBOL tableRef
    usePartition? charsetClause? xmlRowsIdentifiedBy? fieldsClause? linesClause?
    loadDataFileTail

dataOrXml
  = DATA_SYMBOL
  / XML_SYMBOL

xmlRowsIdentifiedBy
  = ROWS_SYMBOL IDENTIFIED_SYMBOL BY_SYMBOL textString

loadDataFileTail
  = (IGNORE_SYMBOL INT_NUMBER (LINES_SYMBOL / ROWS_SYMBOL))?
    loadDataFileTargetList?
    (SET_SYMBOL updateList)?

loadDataFileTargetList
  = OPEN_PAR_SYMBOL fieldOrVariableList? CLOSE_PAR_SYMBOL

fieldOrVariableList
  = (columnRef / userVariable) (COMMA_SYMBOL (columnRef / userVariable))*

//----------------------------------------------------------------------------------------------------------------------

replaceStatement
  = REPLACE_SYMBOL (LOW_PRIORITY_SYMBOL / DELAYED_SYMBOL)? INTO_SYMBOL? tableRef usePartition?
    ( insertFromConstructor
    / SET_SYMBOL updateList
    / insertQueryExpression
    )

//----------------------------------------------------------------------------------------------------------------------

selectStatement
  = queryExpression lockingClauseList?
  / queryExpressionParens
  / selectStatementWithInto

/*
  From the server grammar:

  MySQL has a syntax extension that allows into clauses in any one of two
  places. They may appear either before the from clause or at the end. All in
  a top-level select statement. This extends the standard syntax in two
  ways. First, we don't have the restriction that the result can contain only
  one row: the into clause might be INTO OUTFILE/DUMPFILE in which case any
  number of rows is allowed. Hence MySQL does not have any special case for
  the standard's <select statement: single row>. Secondly, and this has more
  severe implications for the parser, it makes the grammar ambiguous, because
  in a from-clause-less select statement with an into clause, it is not clear
  whether the into clause is the leading or the trailing one.

  While it's possible to write an unambiguous grammar, it would force us to
  duplicate the entire <select statement> syntax all the way down to the <into
  clause>. So instead we solve it by writing an ambiguous grammar and use
  precedence rules to sort out the shift/reduce conflict.

  The problem is when the parser has seen SELECT <select list>, and sees an
  INTO token. It can now either shift it or reduce what it has to a table-less
  query expression. If it shifts the token, it will accept seeing a FROM token
  next and hence the INTO will be interpreted as the leading INTO. If it
  reduces what it has seen to a table-less select, however, it will interpret
  INTO as the trailing into. But what if the next token is FROM? Obviously,
  we want to always shift INTO. We do this by two precedence declarations: We
  make the INTO token right-associative, and we give it higher precedence than
  an empty from clause, using the artificial token EMPTY_FROM_CLAUSE.

  The remaining problem is that now we allow the leading INTO anywhere, when
  it should be allowed on the top level only. We solve this by manually
  throwing parse errors whenever we reduce a nested query expression if it
  contains an into clause.
*/
selectStatementWithInto
  = OPEN_PAR_SYMBOL selectStatementWithInto CLOSE_PAR_SYMBOL
  / queryExpression intoClause lockingClauseList?
  / lockingClauseList intoClause

queryExpression
  = (&{serverVersion >= 80000} withClause)?
    ( queryExpressionBody orderClause? limitClause?
    / queryExpressionParens orderClause? limitClause?
    )
    (&{serverVersion < 80000} procedureAnalyseClause)?

queryExpressionBody
  = ( queryPrimary
    / queryExpressionParens UNION_SYMBOL unionOption?
      ( queryPrimary
      / queryExpressionParens
      )
    )
    (UNION_SYMBOL unionOption? (queryPrimary / queryExpressionParens))*

queryExpressionParens
  = OPEN_PAR_SYMBOL
    ( queryExpressionParens
    / queryExpression lockingClauseList?
    )
    CLOSE_PAR_SYMBOL

queryPrimary
  = querySpecification
  / &{serverVersion >= 80019} tableValueConstructor
  / &{serverVersion >= 80019} explicitTable

querySpecification
  = SELECT_SYMBOL
    selectOption* selectItemList fromClause? whereClause?
    groupByClause? havingClause?
    (&{serverVersion >= 80000} windowClause)?

subquery
  = queryExpressionParens

querySpecOption
  = ALL_SYMBOL
  / DISTINCT_SYMBOL
  / STRAIGHT_JOIN_SYMBOL
  / HIGH_PRIORITY_SYMBOL
  / SQL_SMALL_RESULT_SYMBOL
  / SQL_BIG_RESULT_SYMBOL
  / SQL_BUFFER_RESULT_SYMBOL
  / SQL_CALC_FOUND_ROWS_SYMBOL

limitClause
  = LIMIT_SYMBOL limitOptions

simpleLimitClause
  = LIMIT_SYMBOL limitOption

limitOptions
  = limitOption ((COMMA_SYMBOL / OFFSET_SYMBOL) limitOption)?

limitOption
  = identifier
  / (PARAM_MARKER / ULONGLONG_NUMBER / LONG_NUMBER / INT_NUMBER)

intoClause
  = INTO_SYMBOL
    ( OUTFILE_SYMBOL textStringLiteral charsetClause? fieldsClause? linesClause?
    / DUMPFILE_SYMBOL textStringLiteral
    / (textOrIdentifier / userVariable) (COMMA_SYMBOL (textOrIdentifier / userVariable))*
    )

procedureAnalyseClause
  = PROCEDURE_SYMBOL ANALYSE_SYMBOL
    OPEN_PAR_SYMBOL (INT_NUMBER (COMMA_SYMBOL INT_NUMBER)?)?
    CLOSE_PAR_SYMBOL

havingClause
  = HAVING_SYMBOL expr

windowClause
  = WINDOW_SYMBOL windowDefinition (COMMA_SYMBOL windowDefinition)*

windowDefinition
  = windowName AS_SYMBOL windowSpec

windowSpec
  = OPEN_PAR_SYMBOL windowSpecDetails CLOSE_PAR_SYMBOL

windowSpecDetails
  = windowName?
    (PARTITION_SYMBOL BY_SYMBOL orderList)?
    orderClause? windowFrameClause?

windowFrameClause
  = windowFrameUnits windowFrameExtent windowFrameExclusion?

windowFrameUnits
  = ROWS_SYMBOL
  / RANGE_SYMBOL
  / GROUPS_SYMBOL

windowFrameExtent
  = windowFrameStart
  / windowFrameBetween

windowFrameStart
  = UNBOUNDED_SYMBOL PRECEDING_SYMBOL
  / ulonglong_number PRECEDING_SYMBOL
  / PARAM_MARKER PRECEDING_SYMBOL
  / INTERVAL_SYMBOL expr interval PRECEDING_SYMBOL
  / CURRENT_SYMBOL ROW_SYMBOL

windowFrameBetween
  = BETWEEN_SYMBOL windowFrameBound AND_SYMBOL windowFrameBound

windowFrameBound
  = windowFrameStart
  / UNBOUNDED_SYMBOL FOLLOWING_SYMBOL
  / ulonglong_number FOLLOWING_SYMBOL
  / PARAM_MARKER FOLLOWING_SYMBOL
  / INTERVAL_SYMBOL expr interval FOLLOWING_SYMBOL

windowFrameExclusion
  = EXCLUDE_SYMBOL
    ( CURRENT_SYMBOL ROW_SYMBOL
    / GROUP_SYMBOL
    / TIES_SYMBOL
    / NO_SYMBOL OTHERS_SYMBOL
    )

withClause
  = WITH_SYMBOL RECURSIVE_SYMBOL?
    commonTableExpression (COMMA_SYMBOL commonTableExpression)*

commonTableExpression
  = identifier columnInternalRefList? AS_SYMBOL subquery

groupByClause
  = GROUP_SYMBOL BY_SYMBOL orderList olapOption?

olapOption
  = WITH_SYMBOL ROLLUP_SYMBOL
  / &{serverVersion < 80000} WITH_SYMBOL CUBE_SYMBOL

orderClause
  = ORDER_SYMBOL BY_SYMBOL orderList

direction
  = ASC_SYMBOL
  / DESC_SYMBOL

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
  / SQL_NO_CACHE_SYMBOL // Deprecated and ignored in 8.0.
  / &{serverVersion < 80000} SQL_CACHE_SYMBOL
  / &{serverVersion >= 50704 && serverVersion < 50708} MAX_STATEMENT_TIME_SYMBOL EQUAL_OPERATOR real_ulong_number

lockingClauseList
  = lockingClause+

lockingClause
  = FOR_SYMBOL
    lockStrengh
    (&{serverVersion >= 80000} OF_SYMBOL tableAliasRefList)?
    (&{serverVersion >= 80000}      lockedRowAction)?
  / LOCK_SYMBOL IN_SYMBOL SHARE_SYMBOL MODE_SYMBOL

lockStrengh
  = UPDATE_SYMBOL
  / &{serverVersion >= 80000} SHARE_SYMBOL

lockedRowAction
  = SKIP_SYMBOL LOCKED_SYMBOL
  / NOWAIT_SYMBOL

selectItemList
  = (selectItem / MULT_OPERATOR) (COMMA_SYMBOL selectItem)*

selectItem
  = tableWild
  / expr selectAlias?

selectAlias
  = AS_SYMBOL? (identifier / textStringLiteral)

whereClause
  = WHERE_SYMBOL expr

tableReference // Note: we have also a tableRef rule for identifiers that reference a table anywhere.
  = ( tableFactor
    / OPEN_CURLY_SYMBOL (&{serverVersion < 80017} identifier / OJ_SYMBOL) escapedTableReference CLOSE_CURLY_SYMBOL // ODBC syntax
    )
    joinedTable*

escapedTableReference
  = tableFactor joinedTable*

joinedTable // Same as joined_table in sql_yacc.yy, but with removed left recursion.
  = innerJoinType tableReference
    ( ON_SYMBOL expr
    / USING_SYMBOL identifierListWithParentheses
    )?
  / outerJoinType tableReference
    ( ON_SYMBOL expr
    / USING_SYMBOL identifierListWithParentheses
    )
  / naturalJoinType tableFactor

naturalJoinType
  = NATURAL_SYMBOL INNER_SYMBOL? JOIN_SYMBOL
  / NATURAL_SYMBOL (LEFT_SYMBOL / RIGHT_SYMBOL) OUTER_SYMBOL? JOIN_SYMBOL

innerJoinType
  = (INNER_SYMBOL / CROSS_SYMBOL)? JOIN_SYMBOL
  / STRAIGHT_JOIN_SYMBOL

outerJoinType
  = (LEFT_SYMBOL / RIGHT_SYMBOL) OUTER_SYMBOL? JOIN_SYMBOL

/**
  MySQL has a syntax extension where a comma-separated list of table
  references is allowed as a table reference in itself, for instance

    SELECT * FROM (t1, t2) JOIN t3 ON 1

  which is not allowed in standard SQL. The syntax is equivalent to

    SELECT * FROM (t1 CROSS JOIN t2) JOIN t3 ON 1

  We call this rule tableReferenceListParens.
*/
tableFactor
  = singleTable
  / singleTableParens
  / derivedTable
  / tableReferenceListParens
  / &{serverVersion >= 80004} tableFunction

singleTable
  = tableRef usePartition? tableAlias? indexHintList?

singleTableParens
  = OPEN_PAR_SYMBOL (singleTable / singleTableParens) CLOSE_PAR_SYMBOL

derivedTable
  = subquery tableAlias? (&{serverVersion >= 80000} columnInternalRefList)?
  / &{serverVersion >= 80014}
    LATERAL_SYMBOL subquery tableAlias? columnInternalRefList?

// This rule covers both: joined_table_parens and table_reference_list_parens from sql_yacc.yy.
// We can simplify that because we have unrolled the indirect left recursion in joined_table <-> table_reference.
tableReferenceListParens
  = OPEN_PAR_SYMBOL (tableReferenceList / tableReferenceListParens) CLOSE_PAR_SYMBOL

tableFunction
  = JSON_TABLE_SYMBOL OPEN_PAR_SYMBOL
    expr COMMA_SYMBOL textStringLiteral columnsClause
    CLOSE_PAR_SYMBOL tableAlias?

columnsClause
  = COLUMNS_SYMBOL OPEN_PAR_SYMBOL jtColumn (COMMA_SYMBOL jtColumn)* CLOSE_PAR_SYMBOL

jtColumn
  = identifier FOR_SYMBOL ORDINALITY_SYMBOL
  / identifier
    dataType (&{serverVersion >= 80014} collate)?
    EXISTS_SYMBOL? PATH_SYMBOL textStringLiteral
    onEmptyOrError?
  / NESTED_SYMBOL PATH_SYMBOL textStringLiteral columnsClause

onEmptyOrError
  = onEmpty onError?
  / onError onEmpty?

onEmpty
  = jtOnResponse ON_SYMBOL EMPTY_SYMBOL

onError
  = jtOnResponse ON_SYMBOL ERROR_SYMBOL

jtOnResponse
  = ERROR_SYMBOL
  / NULL_SYMBOL
  / DEFAULT_SYMBOL textStringLiteral

unionOption
  = DISTINCT_SYMBOL
  / ALL_SYMBOL

tableAlias
  = (AS_SYMBOL / &{serverVersion < 80017} EQUAL_OPERATOR)? identifier

indexHintList
  = indexHint (COMMA_SYMBOL indexHint)*

indexHint
  = indexHintType keyOrIndex indexHintClause? OPEN_PAR_SYMBOL indexList CLOSE_PAR_SYMBOL
  / USE_SYMBOL keyOrIndex indexHintClause? OPEN_PAR_SYMBOL indexList? CLOSE_PAR_SYMBOL

indexHintType
  = FORCE_SYMBOL
  / IGNORE_SYMBOL

keyOrIndex
  = KEY_SYMBOL
  / INDEX_SYMBOL

constraintKeyType
  = PRIMARY_SYMBOL KEY_SYMBOL
  / UNIQUE_SYMBOL keyOrIndex?

indexHintClause
  = FOR_SYMBOL (JOIN_SYMBOL / ORDER_SYMBOL BY_SYMBOL / GROUP_SYMBOL BY_SYMBOL)

indexList
  = indexListElement (COMMA_SYMBOL indexListElement)*

indexListElement
  = identifier
  / PRIMARY_SYMBOL

//----------------------------------------------------------------------------------------------------------------------

updateStatement
  = (&{serverVersion >= 80000} withClause)?
    UPDATE_SYMBOL LOW_PRIORITY_SYMBOL? IGNORE_SYMBOL?
    tableReferenceList SET_SYMBOL
    updateList whereClause? orderClause? simpleLimitClause?

//----------------------------------------------------------------------------------------------------------------------

transactionOrLockingStatement
  = transactionStatement
  / savepointStatement
  / lockStatement
  / xaStatement

transactionStatement
  = START_SYMBOL TRANSACTION_SYMBOL transactionCharacteristic*
  / COMMIT_SYMBOL WORK_SYMBOL? (AND_SYMBOL NO_SYMBOL? CHAIN_SYMBOL)? (NO_SYMBOL? RELEASE_SYMBOL)?
  // SET TRANSACTION is part of setStatement.

// BEGIN WORK is separated from transactional statements as it must not appear as part of a stored program.
beginWork
  = BEGIN_SYMBOL WORK_SYMBOL?

transactionCharacteristic
  = WITH_SYMBOL CONSISTENT_SYMBOL SNAPSHOT_SYMBOL
  / &{serverVersion >= 50605} READ_SYMBOL (WRITE_SYMBOL / ONLY_SYMBOL)

savepointStatement
  = SAVEPOINT_SYMBOL identifier
  / ROLLBACK_SYMBOL WORK_SYMBOL?
    ( TO_SYMBOL SAVEPOINT_SYMBOL? identifier
    / (AND_SYMBOL NO_SYMBOL? CHAIN_SYMBOL)? (NO_SYMBOL? RELEASE_SYMBOL)?
    )
  / RELEASE_SYMBOL SAVEPOINT_SYMBOL identifier

lockStatement
  = LOCK_SYMBOL (TABLES_SYMBOL / TABLE_SYMBOL) lockItem (COMMA_SYMBOL lockItem)*
  / &{serverVersion >= 80000} LOCK_SYMBOL INSTANCE_SYMBOL FOR_SYMBOL BACKUP_SYMBOL
  / UNLOCK_SYMBOL
    ( TABLES_SYMBOL
    / TABLE_SYMBOL
    / &{serverVersion >= 80000} INSTANCE_SYMBOL
    )

lockItem
  = tableRef tableAlias? lockOption

lockOption
  = READ_SYMBOL LOCAL_SYMBOL?
  / LOW_PRIORITY_SYMBOL? WRITE_SYMBOL // low priority deprecated since 5.7

xaStatement
  = XA_SYMBOL
    ( (START_SYMBOL / BEGIN_SYMBOL) xid (JOIN_SYMBOL / RESUME_SYMBOL)?
    / END_SYMBOL xid (SUSPEND_SYMBOL (FOR_SYMBOL MIGRATE_SYMBOL)?)?
    / PREPARE_SYMBOL xid
    / COMMIT_SYMBOL xid (ONE_SYMBOL PHASE_SYMBOL)?
    / ROLLBACK_SYMBOL xid
    / RECOVER_SYMBOL xaConvert
    )

xaConvert
  = &{serverVersion >= 50704} (CONVERT_SYMBOL XID_SYMBOL)?

xid
  = textString (COMMA_SYMBOL textString (COMMA_SYMBOL ulong_number)?)?

//----------------------------------------------------------------------------------------------------------------------

resetOption
  = MASTER_SYMBOL masterResetOptions?
  / QUERY_SYMBOL CACHE_SYMBOL
  / SLAVE_SYMBOL ALL_SYMBOL? channel?

masterResetOptions
  = TO_SYMBOL (real_ulong_number / real_ulonglong_number)


replicationStatement
  = PURGE_SYMBOL (BINARY_SYMBOL / MASTER_SYMBOL) LOGS_SYMBOL
    ( TO_SYMBOL textLiteral
    / BEFORE_SYMBOL expr
    )
  / changeMaster
  / RESET_SYMBOL resetOption (COMMA_SYMBOL resetOption)*
  / &{serverVersion > 80000} RESET_SYMBOL PERSIST_SYMBOL (ifExists identifier)?
  / slave
  / &{serverVersion >= 50700} changeReplication
  / replicationLoad
  / &{serverVersion > 50706} groupReplication

replicationLoad
  = LOAD_SYMBOL (DATA_SYMBOL / TABLE_SYMBOL tableRef) FROM_SYMBOL MASTER_SYMBOL

changeMaster
  = CHANGE_SYMBOL MASTER_SYMBOL TO_SYMBOL changeMasterOptions channel?

changeMasterOptions
  = masterOption (COMMA_SYMBOL masterOption)*

masterOption
  = MASTER_HOST_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / NETWORK_NAMESPACE_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_BIND_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_USER_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_PASSWORD_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_PORT_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_CONNECT_RETRY_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_RETRY_COUNT_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_DELAY_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_SSL_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_SSL_CA_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_SSL_CAPATH_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_TLS_VERSION_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_SSL_CERT_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_TLS_CIPHERSUITES_SYMBOL EQUAL_OPERATOR masterTlsCiphersuitesDef
  / MASTER_SSL_CIPHER_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_SSL_KEY_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_SSL_VERIFY_SERVER_CERT_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_SSL_CRL_SYMBOL EQUAL_OPERATOR textLiteral
  / MASTER_SSL_CRLPATH_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_PUBLIC_KEY_PATH_SYMBOL EQUAL_OPERATOR textStringNoLinebreak // Conditionally set in the lexer.
  / GET_MASTER_PUBLIC_KEY_SYMBOL EQUAL_OPERATOR ulong_number           // Conditionally set in the lexer.
  / MASTER_HEARTBEAT_PERIOD_SYMBOL EQUAL_OPERATOR ulong_number
  / IGNORE_SERVER_IDS_SYMBOL EQUAL_OPERATOR serverIdList
  / MASTER_COMPRESSION_ALGORITHM_SYMBOL EQUAL_OPERATOR textStringLiteral
  / MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL EQUAL_OPERATOR ulong_number
  / MASTER_AUTO_POSITION_SYMBOL EQUAL_OPERATOR ulong_number
  / PRIVILEGE_CHECKS_USER_SYMBOL EQUAL_OPERATOR privilegeCheckDef
  / REQUIRE_ROW_FORMAT_SYMBOL EQUAL_OPERATOR ulong_number
  / REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYMBOL EQUAL_OPERATOR tablePrimaryKeyCheckDef
  / masterFileDef

privilegeCheckDef
  = userIdentifierOrText
  / NULL_SYMBOL

tablePrimaryKeyCheckDef
  = STREAM_SYMBOL
  / ON_SYMBOL
  / OFF_SYMBOL

masterTlsCiphersuitesDef
  = textStringNoLinebreak
  / NULL_SYMBOL

masterFileDef
  = MASTER_LOG_FILE_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / MASTER_LOG_POS_SYMBOL EQUAL_OPERATOR ulonglong_number
  / RELAY_LOG_FILE_SYMBOL EQUAL_OPERATOR textStringNoLinebreak
  / RELAY_LOG_POS_SYMBOL EQUAL_OPERATOR ulong_number

serverIdList
  = OPEN_PAR_SYMBOL (ulong_number (COMMA_SYMBOL ulong_number)*)? CLOSE_PAR_SYMBOL

changeReplication
  = CHANGE_SYMBOL REPLICATION_SYMBOL FILTER_SYMBOL
    filterDefinition (COMMA_SYMBOL filterDefinition)*
    (&{serverVersion >= 80000} channel)?

filterDefinition
  = REPLICATE_DO_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterDbList? CLOSE_PAR_SYMBOL
  / REPLICATE_IGNORE_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterDbList? CLOSE_PAR_SYMBOL
  / REPLICATE_DO_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterTableList? CLOSE_PAR_SYMBOL
  / REPLICATE_IGNORE_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterTableList? CLOSE_PAR_SYMBOL
  / REPLICATE_WILD_DO_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterStringList? CLOSE_PAR_SYMBOL
  / REPLICATE_WILD_IGNORE_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterStringList? CLOSE_PAR_SYMBOL
  / REPLICATE_REWRITE_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filterDbPairList? CLOSE_PAR_SYMBOL

filterDbList
  = schemaRef (COMMA_SYMBOL schemaRef)*

filterTableList
  = filterTableRef (COMMA_SYMBOL filterTableRef)*

filterStringList
  = filterWildDbTableString (COMMA_SYMBOL filterWildDbTableString)*

filterWildDbTableString
  = textStringNoLinebreak // sql_yacc.yy checks for the existance of at least one dot char in the string.

filterDbPairList
  = schemaIdentifierPair (COMMA_SYMBOL schemaIdentifierPair)*

slave
  = START_SYMBOL SLAVE_SYMBOL
    slaveThreadOptions? (UNTIL_SYMBOL slaveUntilOptions)? slaveConnectionOptions
    channel?
  / STOP_SYMBOL SLAVE_SYMBOL slaveThreadOptions? channel?

slaveUntilOptions
  = ( masterFileDef
    / &{serverVersion >= 50606} (SQL_BEFORE_GTIDS_SYMBOL / SQL_AFTER_GTIDS_SYMBOL) EQUAL_OPERATOR textString
    / &{serverVersion >= 50606} SQL_AFTER_MTS_GAPS_SYMBOL
    )
    (COMMA_SYMBOL masterFileDef)*

slaveConnectionOptions
  = &{serverVersion >= 50604}
    (USER_SYMBOL EQUAL_OPERATOR textString)?
    (PASSWORD_SYMBOL EQUAL_OPERATOR textString)?
    (DEFAULT_AUTH_SYMBOL EQUAL_OPERATOR textString)?
    (PLUGIN_DIR_SYMBOL EQUAL_OPERATOR textString)?
  

slaveThreadOptions
  = slaveThreadOption (COMMA_SYMBOL slaveThreadOption)*

slaveThreadOption
  = RELAY_THREAD_SYMBOL
  / SQL_THREAD_SYMBOL

groupReplication
  = (START_SYMBOL / STOP_SYMBOL) GROUP_REPLICATION_SYMBOL

//----------------------------------------------------------------------------------------------------------------------

preparedStatement
  = PREPARE_SYMBOL identifier FROM_SYMBOL (textLiteral / userVariable)
  / executeStatement
  / (DEALLOCATE_SYMBOL / DROP_SYMBOL) PREPARE_SYMBOL identifier

executeStatement
  = EXECUTE_SYMBOL identifier (USING_SYMBOL executeVarList)?

executeVarList
  = userVariable (COMMA_SYMBOL userVariable)*

//----------------------------------------------------------------------------------------------------------------------

cloneStatement
  = CLONE_SYMBOL
    ( LOCAL_SYMBOL DATA_SYMBOL DIRECTORY_SYMBOL equal? textStringLiteral
    // Clone remote has been removed in 8.0.14. This alt is taken out by the conditional REMOTE_SYMBOL.
    / REMOTE_SYMBOL (FOR_SYMBOL REPLICATION_SYMBOL)?
    / &{serverVersion >= 80014} INSTANCE_SYMBOL FROM_SYMBOL
      user COLON_SYMBOL ulong_number IDENTIFIED_SYMBOL BY_SYMBOL
      textStringLiteral dataDirSSL?
    )

dataDirSSL
  = ssl
  / DATA_SYMBOL DIRECTORY_SYMBOL equal? textStringLiteral ssl?

ssl
  = REQUIRE_SYMBOL NO_SYMBOL? SSL_SYMBOL

//----------------------------------------------------------------------------------------------------------------------

// Note: SET PASSWORD is part of the SET statement.
accountManagementStatement
  = &{serverVersion >= 50606} alterUser
  / createUser
  / dropUser
  / grant
  / renameUser
  / revoke
  / &{serverVersion >= 80000} setRole

alterUser
  = ALTER_SYMBOL USER_SYMBOL (&{serverVersion >= 50706} ifExists)? alterUserTail

alterUserTail
  = (&{serverVersion < 80014} createUserList / &{serverVersion >= 80014} alterUserList) createUserTail
  / &{serverVersion >= 50706}
    user IDENTIFIED_SYMBOL BY_SYMBOL textString
    (&{serverVersion >= 80014} replacePassword)?
    (&{serverVersion >= 80014} retainCurrentPassword)?
  / &{serverVersion >= 80014} user discardOldPassword
  / &{serverVersion >= 80000}
    user DEFAULT_SYMBOL ROLE_SYMBOL
    ( ALL_SYMBOL
    / NONE_SYMBOL
    / roleList
    )
  / &{serverVersion >= 80018}
    user IDENTIFIED_SYMBOL (WITH_SYMBOL textOrIdentifier)? BY_SYMBOL RANDOM_SYMBOL
    PASSWORD_SYMBOL retainCurrentPassword?
  / FAILED_LOGIN_ATTEMPTS_SYMBOL real_ulong_number
  / PASSWORD_LOCK_TIME_SYMBOL (real_ulong_number / UNBOUNDED_SYMBOL)

userFunction
  = USER_SYMBOL parentheses

createUser
  = CREATE_SYMBOL USER_SYMBOL
    (&{serverVersion >= 50706} ifNotExists )
    createUserList defaultRoleClause createUserTail

createUserTail
  = &{serverVersion >= 50706}
    requireClause? connectOptions? accountLockPasswordExpireOptions*
  

defaultRoleClause
  = &{serverVersion >= 80000} (DEFAULT_SYMBOL ROLE_SYMBOL roleList)?
  

requireClause
  = REQUIRE_SYMBOL (requireList / (SSL_SYMBOL / X509_SYMBOL / NONE_SYMBOL))

connectOptions
  = WITH_SYMBOL
    ( MAX_QUERIES_PER_HOUR_SYMBOL ulong_number
    / MAX_UPDATES_PER_HOUR_SYMBOL ulong_number
    / MAX_CONNECTIONS_PER_HOUR_SYMBOL ulong_number
    / MAX_USER_CONNECTIONS_SYMBOL ulong_number
    )+

accountLockPasswordExpireOptions
  = ACCOUNT_SYMBOL (LOCK_SYMBOL / UNLOCK_SYMBOL)
  / PASSWORD_SYMBOL
    ( EXPIRE_SYMBOL
      ( INTERVAL_SYMBOL real_ulong_number DAY_SYMBOL
      / NEVER_SYMBOL
      / DEFAULT_SYMBOL
      )?
    / HISTORY_SYMBOL (real_ulong_number / DEFAULT_SYMBOL)
    / REUSE_SYMBOL INTERVAL_SYMBOL
      ( real_ulong_number DAY_SYMBOL
      / DEFAULT_SYMBOL
      )
    / &{serverVersion >= 80014} REQUIRE_SYMBOL CURRENT_SYMBOL
      ( DEFAULT_SYMBOL
      / OPTIONAL_SYMBOL
      )?
    )

dropUser
  = DROP_SYMBOL USER_SYMBOL (&{serverVersion >= 50706} ifExists)? userList

grant
  = GRANT_SYMBOL
    ( &{serverVersion >= 80000} roleOrPrivilegesList TO_SYMBOL userList
      (WITH_SYMBOL ADMIN_SYMBOL OPTION_SYMBOL)?
    / (roleOrPrivilegesList / ALL_SYMBOL PRIVILEGES_SYMBOL?)
      ON_SYMBOL aclType? grantIdentifier TO_SYMBOL grantTargetList
      versionedRequireClause? grantOptions? grantAs?
    / PROXY_SYMBOL ON_SYMBOL user TO_SYMBOL grantTargetList (WITH_SYMBOL GRANT_SYMBOL OPTION_SYMBOL)?
    )

grantTargetList
  = &{serverVersion < 80011} createUserList
  / &{serverVersion >= 80011} userList

grantOptions
  = &{serverVersion < 80011} WITH_SYMBOL grantOption+
  / &{serverVersion >= 80011} WITH_SYMBOL GRANT_SYMBOL OPTION_SYMBOL

exceptRoleList
  = EXCEPT_SYMBOL roleList

withRoles
  = WITH_SYMBOL ROLE_SYMBOL
    ( roleList
    / ALL_SYMBOL exceptRoleList?
    / NONE_SYMBOL
    / DEFAULT_SYMBOL
    )

grantAs
  = AS_SYMBOL USER_SYMBOL withRoles?

versionedRequireClause
  = &{serverVersion < 80011} requireClause

renameUser
  = RENAME_SYMBOL USER_SYMBOL user TO_SYMBOL user (COMMA_SYMBOL user TO_SYMBOL user)*

revoke
  = REVOKE_SYMBOL
    ( &{serverVersion >= 80000} roleOrPrivilegesList FROM_SYMBOL userList
    / roleOrPrivilegesList onTypeTo FROM_SYMBOL userList
    / ALL_SYMBOL PRIVILEGES_SYMBOL?
      ( &{serverVersion >= 80000} ON_SYMBOL aclType? grantIdentifier
      / COMMA_SYMBOL GRANT_SYMBOL OPTION_SYMBOL FROM_SYMBOL userList
      )
    / PROXY_SYMBOL ON_SYMBOL user FROM_SYMBOL userList
    )

onTypeTo // Optional, starting with 8.0.1.
  = &{serverVersion < 80000} ON_SYMBOL aclType? grantIdentifier
  / &{serverVersion >= 80000} (ON_SYMBOL aclType? grantIdentifier)?

aclType
  = TABLE_SYMBOL
  / FUNCTION_SYMBOL
  / PROCEDURE_SYMBOL

roleOrPrivilegesList
  = roleOrPrivilege (COMMA_SYMBOL roleOrPrivilege)*

roleOrPrivilege
  = &{serverVersion > 80000}
    ( roleIdentifierOrText columnInternalRefList?
    / roleIdentifierOrText (AT_TEXT_SUFFIX / AT_SIGN_SYMBOL textOrIdentifier)
    )
  / (SELECT_SYMBOL / INSERT_SYMBOL / UPDATE_SYMBOL / REFERENCES_SYMBOL) columnInternalRefList?
  / ( DELETE_SYMBOL
    / USAGE_SYMBOL
    / INDEX_SYMBOL
    / DROP_SYMBOL
    / EXECUTE_SYMBOL
    / RELOAD_SYMBOL
    / SHUTDOWN_SYMBOL
    / PROCESS_SYMBOL
    / FILE_SYMBOL
    / PROXY_SYMBOL
    / SUPER_SYMBOL
    / EVENT_SYMBOL
    / TRIGGER_SYMBOL
    )
  / GRANT_SYMBOL OPTION_SYMBOL
  / SHOW_SYMBOL DATABASES_SYMBOL
  / CREATE_SYMBOL
    ( TEMPORARY_SYMBOL
      TABLES_SYMBOL
    / ( ROUTINE_SYMBOL
        / TABLESPACE_SYMBOL
        / USER_SYMBOL
        / VIEW_SYMBOL
        )
    )?
  / LOCK_SYMBOL TABLES_SYMBOL
  / REPLICATION_SYMBOL
    (CLIENT_SYMBOL / SLAVE_SYMBOL)
  / SHOW_SYMBOL VIEW_SYMBOL
  / ALTER_SYMBOL ROUTINE_SYMBOL?
  / &{serverVersion > 80000} (CREATE_SYMBOL / DROP_SYMBOL) ROLE_SYMBOL

grantIdentifier
  = MULT_OPERATOR (DOT_SYMBOL MULT_OPERATOR)?
  / schemaRef (DOT_SYMBOL MULT_OPERATOR)?
  / tableRef
  / &{serverVersion >= 80017} schemaRef DOT_SYMBOL tableRef

requireList
  = requireListElement (AND_SYMBOL? requireListElement)*

requireListElement
  = CIPHER_SYMBOL textString
  / ISSUER_SYMBOL textString
  / SUBJECT_SYMBOL textString

grantOption
  = GRANT_SYMBOL OPTION_SYMBOL
  / MAX_QUERIES_PER_HOUR_SYMBOL ulong_number
  / MAX_UPDATES_PER_HOUR_SYMBOL ulong_number
  / MAX_CONNECTIONS_PER_HOUR_SYMBOL ulong_number
  / MAX_USER_CONNECTIONS_SYMBOL ulong_number

setRole
  = SET_SYMBOL ROLE_SYMBOL roleList
  / SET_SYMBOL ROLE_SYMBOL (NONE_SYMBOL / DEFAULT_SYMBOL)
  / SET_SYMBOL DEFAULT_SYMBOL ROLE_SYMBOL (roleList / NONE_SYMBOL / ALL_SYMBOL) TO_SYMBOL roleList
  / SET_SYMBOL ROLE_SYMBOL ALL_SYMBOL (EXCEPT_SYMBOL roleList)?

roleList
  = role (COMMA_SYMBOL role)*

role
  = roleIdentifierOrText (AT_SIGN_SYMBOL textOrIdentifier / AT_TEXT_SUFFIX)?

//----------------------------------------------------------------------------------------------------------------------

tableAdministrationStatement
  = ANALYZE_SYMBOL noWriteToBinLog? TABLE_SYMBOL tableRefList
    (&{serverVersion >= 80000} histogram)?
  / CHECK_SYMBOL TABLE_SYMBOL tableRefList checkOption*
  / CHECKSUM_SYMBOL TABLE_SYMBOL tableRefList
    ( QUICK_SYMBOL
    / EXTENDED_SYMBOL
    )?
  / OPTIMIZE_SYMBOL noWriteToBinLog? TABLE_SYMBOL tableRefList
  / REPAIR_SYMBOL noWriteToBinLog? TABLE_SYMBOL tableRefList repairType*

histogram
  = UPDATE_SYMBOL HISTOGRAM_SYMBOL ON_SYMBOL identifierList
    (WITH_SYMBOL INT_NUMBER BUCKETS_SYMBOL)?
  / DROP_SYMBOL HISTOGRAM_SYMBOL ON_SYMBOL identifierList

checkOption
  = FOR_SYMBOL UPGRADE_SYMBOL
  / (QUICK_SYMBOL / FAST_SYMBOL / MEDIUM_SYMBOL / EXTENDED_SYMBOL / CHANGED_SYMBOL)

repairType
  = QUICK_SYMBOL
  / EXTENDED_SYMBOL
  / USE_FRM_SYMBOL

//----------------------------------------------------------------------------------------------------------------------

installUninstallStatment
  = // COMPONENT_SYMBOL is conditionally set in the lexer.
    INSTALL_SYMBOL PLUGIN_SYMBOL identifier SONAME_SYMBOL textStringLiteral
  / INSTALL_SYMBOL COMPONENT_SYMBOL textStringLiteralList
  / UNINSTALL_SYMBOL PLUGIN_SYMBOL pluginRef
  / UNINSTALL_SYMBOL COMPONENT_SYMBOL
    componentRef (COMMA_SYMBOL componentRef)*

//----------------------------------------------------------------------------------------------------------------------

setStatement
  = SET_SYMBOL startOptionValueList

startOptionValueList
  = optionValueNoOptionType optionValueListContinued
  / TRANSACTION_SYMBOL transactionCharacteristics
  / optionType startOptionValueListFollowingOptionType
  / PASSWORD_SYMBOL (FOR_SYMBOL user)?
    equal
    ( textString replacePassword? retainCurrentPassword?
    / textString replacePassword? retainCurrentPassword?
    / &{serverVersion < 50706} OLD_PASSWORD_SYMBOL OPEN_PAR_SYMBOL textString CLOSE_PAR_SYMBOL
    / &{serverVersion < 80014} PASSWORD_SYMBOL OPEN_PAR_SYMBOL textString CLOSE_PAR_SYMBOL
    )
  / &{serverVersion >= 80018}
    PASSWORD_SYMBOL (FOR_SYMBOL user)? TO_SYMBOL RANDOM_SYMBOL
    replacePassword? retainCurrentPassword?

transactionCharacteristics
  = transactionAccessMode isolationLevel?
  / isolationLevel (COMMA_SYMBOL transactionAccessMode)?

transactionAccessMode
  = READ_SYMBOL (WRITE_SYMBOL / ONLY_SYMBOL)

isolationLevel
  = ISOLATION_SYMBOL LEVEL_SYMBOL
    ( REPEATABLE_SYMBOL READ_SYMBOL
    / READ_SYMBOL (COMMITTED_SYMBOL / UNCOMMITTED_SYMBOL)
    / SERIALIZABLE_SYMBOL
    )

optionValueListContinued
  = (COMMA_SYMBOL optionValue)*

optionValueNoOptionType
  = internalVariableName equal setExprOrDefault
  / charsetClause
  / userVariable equal expr
  / setSystemVariable equal setExprOrDefault
  / NAMES_SYMBOL
    ( equal expr
    / charsetName collate?
    / &{serverVersion >= 80011} DEFAULT_SYMBOL
    )

optionValue
  = optionType internalVariableName equal setExprOrDefault
  / optionValueNoOptionType

setSystemVariable
  = AT_AT_SIGN_SYMBOL setVarIdentType? internalVariableName

startOptionValueListFollowingOptionType
  = optionValueFollowingOptionType optionValueListContinued
  / TRANSACTION_SYMBOL transactionCharacteristics

optionValueFollowingOptionType
  = internalVariableName equal setExprOrDefault

setExprOrDefault
  = expr
  / (DEFAULT_SYMBOL / ON_SYMBOL / ALL_SYMBOL / BINARY_SYMBOL)
  / &{serverVersion >= 80000} (ROW_SYMBOL / SYSTEM_SYMBOL)

//----------------------------------------------------------------------------------------------------------------------

showStatement
  = SHOW_SYMBOL
    ( &{serverVersion < 50700}  AUTHORS_SYMBOL
    /  DATABASES_SYMBOL likeOrWhere?
    / showCommandType?  TABLES_SYMBOL inDb? likeOrWhere?
    / FULL_SYMBOL?  TRIGGERS_SYMBOL inDb? likeOrWhere?
    /  EVENTS_SYMBOL inDb? likeOrWhere?
    /  TABLE_SYMBOL STATUS_SYMBOL inDb? likeOrWhere?
    /  OPEN_SYMBOL TABLES_SYMBOL inDb? likeOrWhere?
    /  PLUGINS_SYMBOL
    /  ENGINE_SYMBOL (engineRef / ALL_SYMBOL)
      ( STATUS_SYMBOL
      / MUTEX_SYMBOL
      / LOGS_SYMBOL
      )
    / showCommandType?  COLUMNS_SYMBOL (FROM_SYMBOL / IN_SYMBOL)
      tableRef inDb? likeOrWhere?
    / (BINARY_SYMBOL / MASTER_SYMBOL)  LOGS_SYMBOL
    /  SLAVE_SYMBOL (HOSTS_SYMBOL / STATUS_SYMBOL nonBlocking channel?)
    /  (BINLOG_SYMBOL / RELAYLOG_SYMBOL) EVENTS_SYMBOL
      (IN_SYMBOL textString)?
      (FROM_SYMBOL ulonglong_number)? limitClause? channel?
    / (&{serverVersion >= 80000} EXTENDED_SYMBOL)?
      ( INDEX_SYMBOL
        / INDEXES_SYMBOL
        / KEYS_SYMBOL
        )
      fromOrIn tableRef inDb? whereClause?
    / STORAGE_SYMBOL?  ENGINES_SYMBOL
    / COUNT_SYMBOL OPEN_PAR_SYMBOL MULT_OPERATOR CLOSE_PAR_SYMBOL
      ( WARNINGS_SYMBOL
        / ERRORS_SYMBOL
        )
    /  WARNINGS_SYMBOL limitClause?
    /  ERRORS_SYMBOL limitClause?
    /  PROFILES_SYMBOL
    /  PROFILE_SYMBOL (profileType (COMMA_SYMBOL profileType)*)?
      (FOR_SYMBOL QUERY_SYMBOL INT_NUMBER)? limitClause?
    / optionType?  (STATUS_SYMBOL / VARIABLES_SYMBOL) likeOrWhere?
    / FULL_SYMBOL?  PROCESSLIST_SYMBOL
    / charset likeOrWhere?
    /  COLLATION_SYMBOL likeOrWhere?
    / &{serverVersion < 50700}  CONTRIBUTORS_SYMBOL
    /  PRIVILEGES_SYMBOL
    /  GRANTS_SYMBOL (FOR_SYMBOL user)?
    /  GRANTS_SYMBOL FOR_SYMBOL user USING_SYMBOL userList
    /  MASTER_SYMBOL STATUS_SYMBOL
    /  CREATE_SYMBOL
      ( DATABASE_SYMBOL ifNotExists? schemaRef
      / EVENT_SYMBOL eventRef
      / FUNCTION_SYMBOL functionRef
      / PROCEDURE_SYMBOL procedureRef
      / TABLE_SYMBOL tableRef
      / TRIGGER_SYMBOL triggerRef
      / VIEW_SYMBOL viewRef
      / &{serverVersion >= 50704} USER_SYMBOL user
      )
    /  PROCEDURE_SYMBOL STATUS_SYMBOL likeOrWhere?
    /  FUNCTION_SYMBOL STATUS_SYMBOL likeOrWhere?
    /  PROCEDURE_SYMBOL CODE_SYMBOL procedureRef
    /  FUNCTION_SYMBOL CODE_SYMBOL functionRef
    )

showCommandType
  = FULL_SYMBOL
  / &{serverVersion >= 80000} EXTENDED_SYMBOL FULL_SYMBOL?

nonBlocking
  = &{serverVersion >= 50700 && serverVersion < 50706} NONBLOCKING_SYMBOL?
  

fromOrIn
  = FROM_SYMBOL
  / IN_SYMBOL

inDb
  = fromOrIn identifier

profileType
  = BLOCK_SYMBOL IO_SYMBOL
  / CONTEXT_SYMBOL SWITCHES_SYMBOL
  / PAGE_SYMBOL FAULTS_SYMBOL
  / ( ALL_SYMBOL
    / CPU_SYMBOL
    / IPC_SYMBOL
    / MEMORY_SYMBOL
    / SOURCE_SYMBOL
    / SWAPS_SYMBOL
    )

//----------------------------------------------------------------------------------------------------------------------

otherAdministrativeStatement
  = BINLOG_SYMBOL textLiteral
  / CACHE_SYMBOL INDEX_SYMBOL keyCacheListOrParts
    IN_SYMBOL
    ( identifier
    / DEFAULT_SYMBOL
    )
  / FLUSH_SYMBOL noWriteToBinLog?
    ( flushTables
    / flushOption (COMMA_SYMBOL flushOption)*
    )
  / KILL_SYMBOL (CONNECTION_SYMBOL / QUERY_SYMBOL)? expr
  / LOAD_SYMBOL INDEX_SYMBOL INTO_SYMBOL CACHE_SYMBOL preloadTail
  / &{serverVersion >= 50709} SHUTDOWN_SYMBOL

keyCacheListOrParts
  = keyCacheList
  / assignToKeycachePartition

keyCacheList
  = assignToKeycache (COMMA_SYMBOL assignToKeycache)*

assignToKeycache
  = tableRef cacheKeyList?

assignToKeycachePartition
  = tableRef PARTITION_SYMBOL OPEN_PAR_SYMBOL allOrPartitionNameList CLOSE_PAR_SYMBOL cacheKeyList?

cacheKeyList
  = keyOrIndex OPEN_PAR_SYMBOL keyUsageList? CLOSE_PAR_SYMBOL

keyUsageElement
  = identifier
  / PRIMARY_SYMBOL

keyUsageList
  = keyUsageElement (COMMA_SYMBOL keyUsageElement)*

flushOption
  = ( DES_KEY_FILE_SYMBOL // No longer used from 8.0 onwards. Taken out by lexer.
      / HOSTS_SYMBOL
      / PRIVILEGES_SYMBOL
      / STATUS_SYMBOL
      / USER_RESOURCES_SYMBOL
      )
  / logType? LOGS_SYMBOL
  / RELAY_SYMBOL LOGS_SYMBOL channel?
  / &{serverVersion < 80000} QUERY_SYMBOL CACHE_SYMBOL
  / &{serverVersion >= 50706} OPTIMIZER_COSTS_SYMBOL

logType
  = BINARY_SYMBOL
  / ENGINE_SYMBOL
  / ERROR_SYMBOL
  / GENERAL_SYMBOL
  / SLOW_SYMBOL

flushTables
  = (TABLES_SYMBOL / TABLE_SYMBOL)
    ( WITH_SYMBOL READ_SYMBOL LOCK_SYMBOL
    / identifierList flushTablesOptions?
    )?

flushTablesOptions
  = &{serverVersion >= 50606} FOR_SYMBOL EXPORT_SYMBOL
  / WITH_SYMBOL READ_SYMBOL LOCK_SYMBOL

preloadTail
  = tableRef adminPartition cacheKeyList? (IGNORE_SYMBOL LEAVES_SYMBOL)?
  / preloadList

preloadList
  = preloadKeys (COMMA_SYMBOL preloadKeys)*

preloadKeys
  = tableRef cacheKeyList?  (IGNORE_SYMBOL LEAVES_SYMBOL)?

adminPartition
  = PARTITION_SYMBOL OPEN_PAR_SYMBOL allOrPartitionNameList CLOSE_PAR_SYMBOL

//----------------------------------------------------------------------------------------------------------------------

resourceGroupManagement
  = createResourceGroup
  / alterResourceGroup
  / setResourceGroup
  / dropResourceGroup

createResourceGroup
  = CREATE_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL identifier
    TYPE_SYMBOL equal?
    ( USER_SYMBOL
    / SYSTEM_SYMBOL
    )
    resourceGroupVcpuList? resourceGroupPriority? resourceGroupEnableDisable?

resourceGroupVcpuList
  = VCPU_SYMBOL equal? vcpuNumOrRange (COMMA_SYMBOL? vcpuNumOrRange)*

vcpuNumOrRange
  = INT_NUMBER (MINUS_OPERATOR INT_NUMBER)?

resourceGroupPriority
  = THREAD_PRIORITY_SYMBOL equal? INT_NUMBER

resourceGroupEnableDisable
  = ENABLE_SYMBOL
  / DISABLE_SYMBOL

alterResourceGroup
  = ALTER_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL resourceGroupRef
    resourceGroupVcpuList? resourceGroupPriority?
    resourceGroupEnableDisable? FORCE_SYMBOL?

setResourceGroup
  = SET_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL identifier (FOR_SYMBOL threadIdList)?

threadIdList
  = real_ulong_number (COMMA_SYMBOL? real_ulong_number)*

dropResourceGroup
  = DROP_SYMBOL RESOURCE_SYMBOL GROUP_SYMBOL resourceGroupRef FORCE_SYMBOL?

//----------------------------------------------------------------------------------------------------------------------

utilityStatement
  = describeStatement
  / explainStatement
  / helpCommand
  / useCommand
  / &{serverVersion >= 80011} restartServer

describeStatement
  = (EXPLAIN_SYMBOL / DESCRIBE_SYMBOL / DESC_SYMBOL) tableRef
    ( textString
    / columnRef
    )?

explainStatement
  = (EXPLAIN_SYMBOL / DESCRIBE_SYMBOL / DESC_SYMBOL)
    ( &{serverVersion < 80000} EXTENDED_SYMBOL
    / &{serverVersion < 80000} PARTITIONS_SYMBOL
    / &{serverVersion >= 50605} FORMAT_SYMBOL EQUAL_OPERATOR textOrIdentifier
    / &{serverVersion >= 80018} ANALYZE_SYMBOL
    / &{serverVersion >= 80019} ANALYZE_SYMBOL FORMAT_SYMBOL EQUAL_OPERATOR textOrIdentifier
    )? explainableStatement

// Before server version 5.6 only select statements were explainable.
explainableStatement
  = selectStatement
  / &{serverVersion >= 50603} (deleteStatement / insertStatement / replaceStatement / updateStatement)
  / &{serverVersion >= 50700} FOR_SYMBOL CONNECTION_SYMBOL real_ulong_number

helpCommand
  = HELP_SYMBOL textOrIdentifier

useCommand
  = USE_SYMBOL identifier

restartServer
  = RESTART_SYMBOL

//----------------- Expression support ---------------------------------------------------------------------------------

expr
  = head:exprPrimary tail:exprTail* {
      return tail.reduce((result, element) => {
        return {
          type: element.type,
          left: result,
          operator: element.operator,
          right: element.right
        };
      }, head);
    }

exprPrimary
  = boolPri (IS_SYMBOL notRule? (TRUE_SYMBOL / FALSE_SYMBOL / UNKNOWN_SYMBOL))?
  / NOT_SYMBOL exprPrimary

exprTail
  = (AND_SYMBOL / LOGICAL_AND_OPERATOR) right:expr { return { type: 'AND', operator: text(), right }; }
  / XOR_SYMBOL right:expr { return { type: 'XOR', operator: 'XOR', right }; }
  / (OR_SYMBOL / LOGICAL_OR_OPERATOR) right:expr { return { type: 'OR', operator: text(), right }; }
                    

/*
boolPri
  = predicate                                           
  / boolPri IS_SYMBOL notRule? NULL_SYMBOL            
  / boolPri compOp predicate                          
  / boolPri compOp (ALL_SYMBOL / ANY_SYMBOL) subquery 
  / &{serverVersion >= 80017} boolPri MEMBER_SYMBOL OF_SYMBOL? simpleExprWithParentheses
  / boolPri SOUNDS_SYMBOL LIKE_SYMBOL bitExpr
*/

boolPri
  = head:predicate tail:boolPriTail* {
      return tail.reduce((result, element) => {
        return {
          type: element.type,
          left: result,
          operator: element.operator,
          right: element.right
        };
      }, head);
    }

boolPriTail
  = IS_SYMBOL not:notRule? NULL_SYMBOL { return { type: 'IS_NULL', operator: 'IS', not, right: 'NULL' }; }
  / compOp right:predicate { return { type: 'COMP_OP', operator: text(), right }; }
  / compOp (ALL_SYMBOL / ANY_SYMBOL) subquery { return { type: 'COMP_OP_SUBQUERY', operator: text(), subquery }; }
  / &{serverVersion >= 80017} MEMBER_SYMBOL OF_SYMBOL? right:simpleExprWithParentheses { return { type: 'MEMBER_OF', operator: 'MEMBER OF', right }; }
  / SOUNDS_SYMBOL LIKE_SYMBOL right:bitExpr { return { type: 'SOUNDS_LIKE', operator: 'SOUNDS LIKE', right }; }


compOp
  = EQUAL_OPERATOR
  / NULL_SAFE_EQUAL_OPERATOR
  / GREATER_OR_EQUAL_OPERATOR
  / GREATER_THAN_OPERATOR
  / LESS_OR_EQUAL_OPERATOR
  / LESS_THAN_OPERATOR
  / NOT_EQUAL_OPERATOR

predicate
  = bitExpr
    ( notRule? predicateOperations
    / &{serverVersion >= 80017} MEMBER_SYMBOL OF_SYMBOL? simpleExprWithParentheses
    / SOUNDS_SYMBOL LIKE_SYMBOL bitExpr
    )?

predicateOperations
  = IN_SYMBOL (subquery / OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL) 
  / BETWEEN_SYMBOL bitExpr AND_SYMBOL predicate                    
  / LIKE_SYMBOL simpleExpr (ESCAPE_SYMBOL simpleExpr)?             
  / REGEXP_SYMBOL bitExpr                                          

/*
bitExpr
  = simpleExpr
  / bitExpr BITWISE_XOR_OPERATOR bitExpr
  / bitExpr
    ( MULT_OPERATOR
      / DIV_OPERATOR
      / MOD_OPERATOR
      / DIV_SYMBOL
      / MOD_SYMBOL
      )
    bitExpr
  / bitExpr (PLUS_OPERATOR / MINUS_OPERATOR) bitExpr
  / bitExpr (PLUS_OPERATOR / MINUS_OPERATOR) INTERVAL_SYMBOL expr interval
  / bitExpr (SHIFT_LEFT_OPERATOR / SHIFT_RIGHT_OPERATOR) bitExpr
  / bitExpr BITWISE_AND_OPERATOR bitExpr
  / bitExpr BITWISE_OR_OPERATOR bitExpr
*/

bitExpr
  = head:simpleExpr tail:bitExprTail* {
      return tail.reduce((result, element) => {
        return {
          type: element.type,
          left: result,
          operator: element.operator,
          right: element.right
        };
      }, head);
    }

bitExprTail
  = BITWISE_XOR_OPERATOR right:simpleExpr { return { type: 'BITWISE_XOR', operator: '^', right }; }
  / (MULT_OPERATOR / DIV_OPERATOR / MOD_OPERATOR / DIV_SYMBOL / MOD_SYMBOL) right:simpleExpr { return { type: 'MULT_DIV_MOD', operator: text(), right }; }
  / (PLUS_OPERATOR / MINUS_OPERATOR) right:simpleExpr { return { type: 'PLUS_MINUS', operator: text(), right }; }
  / (PLUS_OPERATOR / MINUS_OPERATOR) INTERVAL_SYMBOL expr:expr interval:interval { return { type: 'PLUS_MINUS_INTERVAL', operator: text(), expr, interval }; }
  / (SHIFT_LEFT_OPERATOR / SHIFT_RIGHT_OPERATOR) right:simpleExpr { return { type: 'SHIFT', operator: text(), right }; }
  / BITWISE_AND_OPERATOR right:simpleExpr { return { type: 'BITWISE_AND', operator: '&', right }; }
  / BITWISE_OR_OPERATOR right:simpleExpr { return { type: 'BITWISE_OR', operator: '|', right }; }


simpleExpr
  = head:simpleExprPrimary tail:simpleExprTail* {
      return tail.reduce((result, element) => {
        return {
          type: element.type,
          left: result,
          operator: element.operator,
          right: element.right
        };
      }, head);
    }

simpleExprPrimary
  = variable (equal expr)?
  / columnRef jsonOperator?
  / runtimeFunctionCall
  / functionCall
  / literal
  / PARAM_MARKER
  / sumExpr
  / &{serverVersion >= 80000} groupingOperation
  / &{serverVersion >= 80000} windowFunctionCall
  / (PLUS_OPERATOR / MINUS_OPERATOR / BITWISE_NOT_OPERATOR) simpleExprPrimary
  / not2Rule simpleExprPrimary
  / ROW_SYMBOL? OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL
  / EXISTS_SYMBOL? subquery
  / OPEN_CURLY_SYMBOL identifier expr CLOSE_CURLY_SYMBOL
  / MATCH_SYMBOL identListArg AGAINST_SYMBOL OPEN_PAR_SYMBOL bitExpr fulltextOptions? CLOSE_PAR_SYMBOL
  / BINARY_SYMBOL simpleExprPrimary
  / CAST_SYMBOL OPEN_PAR_SYMBOL expr AS_SYMBOL castType arrayCast? CLOSE_PAR_SYMBOL
  / CASE_SYMBOL expr? (whenExpression thenExpression)+ elseExpression? END_SYMBOL
  / CONVERT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL castType CLOSE_PAR_SYMBOL
  / CONVERT_SYMBOL OPEN_PAR_SYMBOL expr USING_SYMBOL charsetName CLOSE_PAR_SYMBOL
  / DEFAULT_SYMBOL OPEN_PAR_SYMBOL simpleIdentifier CLOSE_PAR_SYMBOL
  / VALUES_SYMBOL OPEN_PAR_SYMBOL simpleIdentifier CLOSE_PAR_SYMBOL
  / INTERVAL_SYMBOL expr interval PLUS_OPERATOR expr

simpleExprTail
  = COLLATE_SYMBOL right:textOrIdentifier { return { type: 'COLLATE', operator: 'COLLATE', right }; }
  / CONCAT_PIPES_SYMBOL right:simpleExpr { return { type: 'CONCAT', operator: '||', right }; }
  / INTERVAL_SYMBOL expr interval PLUS_OPERATOR right:expr { return { type: 'INTERVAL_PLUS', operator: '+', expr, interval, right }; }


arrayCast
  = &{serverVersion >= 80017} ARRAY_SYMBOL

jsonOperator
  = &{serverVersion >= 50708} JSON_SEPARATOR_SYMBOL textStringLiteral
  / &{serverVersion >= 50713} JSON_UNQUOTED_SEPARATOR_SYMBOL textStringLiteral

sumExpr
  =  AVG_SYMBOL
    OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  (BIT_AND_SYMBOL / BIT_OR_SYMBOL / BIT_XOR_SYMBOL)
    OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  / &{serverVersion >= 80000} jsonFunction
  /  COUNT_SYMBOL
    OPEN_PAR_SYMBOL ALL_SYMBOL? MULT_OPERATOR CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  COUNT_SYMBOL
    OPEN_PAR_SYMBOL
    ( ALL_SYMBOL? MULT_OPERATOR
    / inSumExpr
    / DISTINCT_SYMBOL exprList
    )
    CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  MIN_SYMBOL
    OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  MAX_SYMBOL
    OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  STD_SYMBOL
    OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  VARIANCE_SYMBOL
    OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  STDDEV_SAMP_SYMBOL
    OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  VAR_SAMP_SYMBOL
    OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  SUM_SYMBOL
    OPEN_PAR_SYMBOL DISTINCT_SYMBOL? inSumExpr CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?
  /  GROUP_CONCAT_SYMBOL
    OPEN_PAR_SYMBOL DISTINCT_SYMBOL? exprList orderClause?
    (SEPARATOR_SYMBOL textString)? CLOSE_PAR_SYMBOL
    (&{serverVersion >= 80000} windowingClause)?

groupingOperation
  = GROUPING_SYMBOL OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL

windowFunctionCall
  = ( ROW_NUMBER_SYMBOL
    / RANK_SYMBOL
    / DENSE_RANK_SYMBOL
    / CUME_DIST_SYMBOL
    / PERCENT_RANK_SYMBOL
    )
    parentheses windowingClause
  / NTILE_SYMBOL simpleExprWithParentheses windowingClause
  / (LEAD_SYMBOL / LAG_SYMBOL)
    OPEN_PAR_SYMBOL expr leadLagInfo? CLOSE_PAR_SYMBOL
    nullTreatment? windowingClause
  / (FIRST_VALUE_SYMBOL / LAST_VALUE_SYMBOL)
    exprWithParentheses nullTreatment? windowingClause
  / NTH_VALUE_SYMBOL
    OPEN_PAR_SYMBOL expr COMMA_SYMBOL simpleExpr CLOSE_PAR_SYMBOL
    (FROM_SYMBOL (FIRST_SYMBOL / LAST_SYMBOL))?
    nullTreatment? windowingClause

windowingClause
  = OVER_SYMBOL (windowName / windowSpec)

leadLagInfo
  = COMMA_SYMBOL (ulonglong_number / PARAM_MARKER) (COMMA_SYMBOL expr)?

nullTreatment
  = (RESPECT_SYMBOL / IGNORE_SYMBOL) NULLS_SYMBOL

jsonFunction
  = JSON_ARRAYAGG_SYMBOL OPEN_PAR_SYMBOL inSumExpr CLOSE_PAR_SYMBOL windowingClause?
  / JSON_OBJECTAGG_SYMBOL
    OPEN_PAR_SYMBOL inSumExpr COMMA_SYMBOL inSumExpr
    CLOSE_PAR_SYMBOL windowingClause?

inSumExpr
  = ALL_SYMBOL? expr

identListArg
  = identList
  / OPEN_PAR_SYMBOL identList CLOSE_PAR_SYMBOL

identList
  = simpleIdentifier (COMMA_SYMBOL simpleIdentifier)*

fulltextOptions
  = IN_SYMBOL BOOLEAN_SYMBOL MODE_SYMBOL
  / IN_SYMBOL NATURAL_SYMBOL LANGUAGE_SYMBOL MODE_SYMBOL
    (WITH_SYMBOL QUERY_SYMBOL EXPANSION_SYMBOL)?
  / WITH_SYMBOL QUERY_SYMBOL EXPANSION_SYMBOL

runtimeFunctionCall
  = // Function names that are keywords.
     CHAR_SYMBOL OPEN_PAR_SYMBOL
    exprList (USING_SYMBOL charsetName)?
    CLOSE_PAR_SYMBOL
  /  CURRENT_USER_SYMBOL parentheses?
  /  DATE_SYMBOL exprWithParentheses
  /  DAY_SYMBOL exprWithParentheses
  /  HOUR_SYMBOL exprWithParentheses
  /  INSERT_SYMBOL
    OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr
    CLOSE_PAR_SYMBOL
  /  INTERVAL_SYMBOL OPEN_PAR_SYMBOL expr (COMMA_SYMBOL expr)+ CLOSE_PAR_SYMBOL
  /  LEFT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  MINUTE_SYMBOL exprWithParentheses
  /  MONTH_SYMBOL exprWithParentheses
  /  RIGHT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  SECOND_SYMBOL exprWithParentheses
  /  TIME_SYMBOL exprWithParentheses
  /  TIMESTAMP_SYMBOL OPEN_PAR_SYMBOL expr (COMMA_SYMBOL expr)? CLOSE_PAR_SYMBOL
  / trimFunction
  /  USER_SYMBOL parentheses
  /  VALUES_SYMBOL exprWithParentheses
  /  YEAR_SYMBOL exprWithParentheses
  // Function names that are not keywords.
  /  (ADDDATE_SYMBOL / SUBDATE_SYMBOL)
    OPEN_PAR_SYMBOL expr COMMA_SYMBOL
    ( expr
    / INTERVAL_SYMBOL expr interval
    )
    CLOSE_PAR_SYMBOL
  /  CURDATE_SYMBOL parentheses?
  /  CURTIME_SYMBOL timeFunctionParameters?
  /  (DATE_ADD_SYMBOL / DATE_SUB_SYMBOL)
    OPEN_PAR_SYMBOL expr COMMA_SYMBOL INTERVAL_SYMBOL expr interval
    CLOSE_PAR_SYMBOL
  /  EXTRACT_SYMBOL OPEN_PAR_SYMBOL interval FROM_SYMBOL expr CLOSE_PAR_SYMBOL
  /  GET_FORMAT_SYMBOL OPEN_PAR_SYMBOL dateTimeTtype COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  NOW_SYMBOL timeFunctionParameters?
  /  POSITION_SYMBOL OPEN_PAR_SYMBOL bitExpr IN_SYMBOL expr CLOSE_PAR_SYMBOL
  / substringFunction
  /  SYSDATE_SYMBOL timeFunctionParameters?
  /  (TIMESTAMP_ADD_SYMBOL / TIMESTAMP_DIFF_SYMBOL)
    OPEN_PAR_SYMBOL intervalTimeStamp COMMA_SYMBOL expr COMMA_SYMBOL expr
    CLOSE_PAR_SYMBOL
  /  UTC_DATE_SYMBOL parentheses?
  /  UTC_TIME_SYMBOL timeFunctionParameters?
  /  UTC_TIMESTAMP_SYMBOL timeFunctionParameters?
  // Function calls with other conflicts.
  /  ASCII_SYMBOL exprWithParentheses
  /  CHARSET_SYMBOL exprWithParentheses
  /  COALESCE_SYMBOL exprListWithParentheses
  /  COLLATION_SYMBOL exprWithParentheses
  /  DATABASE_SYMBOL parentheses
  /  IF_SYMBOL
    OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr
    CLOSE_PAR_SYMBOL
  /  FORMAT_SYMBOL
    OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr (COMMA_SYMBOL expr)?
    CLOSE_PAR_SYMBOL
  /  MICROSECOND_SYMBOL exprWithParentheses
  /  MOD_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  / &{serverVersion < 50607}  OLD_PASSWORD_SYMBOL OPEN_PAR_SYMBOL textLiteral CLOSE_PAR_SYMBOL
  / &{serverVersion < 80011}  PASSWORD_SYMBOL exprWithParentheses
  /  QUARTER_SYMBOL exprWithParentheses
  /  REPEAT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  REPLACE_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  REVERSE_SYMBOL exprWithParentheses
  /  ROW_COUNT_SYMBOL parentheses
  /  SCHEMA_SYMBOL parentheses
  /  SESSION_USER_SYMBOL parentheses
  /  SYSTEM_USER_SYMBOL parentheses
  /  TRUNCATE_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  WEEK_SYMBOL OPEN_PAR_SYMBOL expr (COMMA_SYMBOL expr)? CLOSE_PAR_SYMBOL
  /  WEIGHT_STRING_SYMBOL
    OPEN_PAR_SYMBOL expr
    ( (AS_SYMBOL CHAR_SYMBOL wsNumCodepoints)?
      (&{serverVersion < 80000} weightStringLevels)?
    / AS_SYMBOL BINARY_SYMBOL wsNumCodepoints
    / COMMA_SYMBOL ulong_number COMMA_SYMBOL ulong_number COMMA_SYMBOL ulong_number
    )
    CLOSE_PAR_SYMBOL
  / geometryFunction

geometryFunction
  = &{serverVersion < 50706}
     CONTAINS_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  GEOMETRYCOLLECTION_SYMBOL OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL
  /  LINESTRING_SYMBOL exprListWithParentheses
  /  MULTILINESTRING_SYMBOL exprListWithParentheses
  /  MULTIPOINT_SYMBOL exprListWithParentheses
  /  MULTIPOLYGON_SYMBOL exprListWithParentheses
  /  POINT_SYMBOL OPEN_PAR_SYMBOL expr COMMA_SYMBOL expr CLOSE_PAR_SYMBOL
  /  POLYGON_SYMBOL exprListWithParentheses

timeFunctionParameters
  = OPEN_PAR_SYMBOL fractionalPrecision? CLOSE_PAR_SYMBOL

fractionalPrecision
  = &{serverVersion >= 50604} INT_NUMBER

weightStringLevels
  = LEVEL_SYMBOL
    ( real_ulong_number MINUS_OPERATOR real_ulong_number
    / weightStringLevelListItem (COMMA_SYMBOL weightStringLevelListItem)*
    )

weightStringLevelListItem
  = real_ulong_number ((ASC_SYMBOL / DESC_SYMBOL) REVERSE_SYMBOL? / REVERSE_SYMBOL)?

dateTimeTtype
  = DATE_SYMBOL
  / TIME_SYMBOL
  / DATETIME_SYMBOL
  / TIMESTAMP_SYMBOL

trimFunction
  = TRIM_SYMBOL OPEN_PAR_SYMBOL
    ( expr (FROM_SYMBOL expr)?
    / LEADING_SYMBOL expr? FROM_SYMBOL expr
    / TRAILING_SYMBOL expr? FROM_SYMBOL expr
    / BOTH_SYMBOL expr? FROM_SYMBOL expr
    )
    CLOSE_PAR_SYMBOL

substringFunction
  = (SUBSTRING_SYMBOL / SUBSTR_SYMBOL)
    OPEN_PAR_SYMBOL expr
    ( COMMA_SYMBOL expr (COMMA_SYMBOL expr)?
    / FROM_SYMBOL expr (FOR_SYMBOL expr)?
    )
    CLOSE_PAR_SYMBOL

functionCall
  = pureIdentifier OPEN_PAR_SYMBOL udfExprList? CLOSE_PAR_SYMBOL     // For both UDF + other functions.
  / qualifiedIdentifier OPEN_PAR_SYMBOL exprList? CLOSE_PAR_SYMBOL // Other functions only.

udfExprList
  = udfExpr (COMMA_SYMBOL udfExpr)*

udfExpr
  = expr selectAlias?

variable
  = userVariable
  / systemVariable

userVariable
  = AT_SIGN_SYMBOL textOrIdentifier
  / AT_TEXT_SUFFIX

systemVariable
  = AT_AT_SIGN_SYMBOL varIdentType? textOrIdentifier dotIdentifier?

internalVariableName
  = ( &{serverVersion < 80017} identifier dotIdentifier?
    / &{serverVersion >= 80017} lValueIdentifier dotIdentifier?
    )
  / DEFAULT_SYMBOL dotIdentifier

whenExpression
  = WHEN_SYMBOL expr

thenExpression
  = THEN_SYMBOL expr

elseExpression
  = ELSE_SYMBOL expr

castType
  = BINARY_SYMBOL fieldLength?
  / CHAR_SYMBOL fieldLength? charsetWithOptBinary?
  / nchar fieldLength?
  / SIGNED_SYMBOL INT_SYMBOL?
  / UNSIGNED_SYMBOL INT_SYMBOL?
  / DATE_SYMBOL
  / TIME_SYMBOL typeDatetimePrecision?
  / DATETIME_SYMBOL typeDatetimePrecision?
  / DECIMAL_SYMBOL floatOptions?
  / &{serverVersion >= 50708} JSON_SYMBOL
  / &{serverVersion >= 80017} realType precision?
  / &{serverVersion >= 80017} FLOAT_SYMBOL standardFloatOptions?

exprList
  = expr (COMMA_SYMBOL expr)*

exprListWithParentheses
  = OPEN_PAR_SYMBOL exprList CLOSE_PAR_SYMBOL

exprWithParentheses
  = OPEN_PAR_SYMBOL expr CLOSE_PAR_SYMBOL

simpleExprWithParentheses
  = OPEN_PAR_SYMBOL simpleExpr CLOSE_PAR_SYMBOL

orderList
  = orderExpression (COMMA_SYMBOL orderExpression)*

orderExpression
  = expr direction?

groupList
  = groupingExpression (COMMA_SYMBOL groupingExpression)*

groupingExpression
  = expr

channel
  = &{serverVersion >= 50706} FOR_SYMBOL CHANNEL_SYMBOL textStringNoLinebreak

//----------------- Stored routines rules ------------------------------------------------------------------------------

// Compound syntax for stored procedures, stored functions, triggers and events.
// Implements both, sp_proc_stmt and ev_sql_stmt_inner from the server grammar.
compoundStatement
  = simpleStatement
  / returnStatement
  / ifStatement
  / caseStatement
  / labeledBlock
  / unlabeledBlock
  / labeledControl
  / unlabeledControl
  / leaveStatement
  / iterateStatement
  / cursorOpen
  / cursorFetch
  / cursorClose
  / spDeclarations

returnStatement
  = RETURN_SYMBOL expr

ifStatement
  = IF_SYMBOL ifBody END_SYMBOL IF_SYMBOL

ifBody
  = expr thenStatement (ELSEIF_SYMBOL ifBody / ELSE_SYMBOL compoundStatementList)?

thenStatement
  = THEN_SYMBOL compoundStatementList

compoundStatementList
  = (compoundStatement SEMICOLON_SYMBOL)+

caseStatement
  = CASE_SYMBOL expr? (whenExpression thenStatement)+ elseStatement? END_SYMBOL CASE_SYMBOL

elseStatement
  = ELSE_SYMBOL compoundStatementList

labeledBlock
  = label beginEndBlock labelRef?

unlabeledBlock
  = beginEndBlock

label
  = // Block labels can only be up to 16 characters long.
    labelIdentifier COLON_SYMBOL

beginEndBlock
  = BEGIN_SYMBOL spDeclarations? compoundStatementList? END_SYMBOL

labeledControl
  = label unlabeledControl labelRef?

unlabeledControl
  = loopBlock
  / whileDoBlock
  / repeatUntilBlock

loopBlock
  = LOOP_SYMBOL compoundStatementList END_SYMBOL LOOP_SYMBOL

whileDoBlock
  = WHILE_SYMBOL expr DO_SYMBOL compoundStatementList END_SYMBOL WHILE_SYMBOL

repeatUntilBlock
  = REPEAT_SYMBOL compoundStatementList UNTIL_SYMBOL expr END_SYMBOL REPEAT_SYMBOL

spDeclarations
  = (spDeclaration SEMICOLON_SYMBOL)+

spDeclaration
  = DECLARE_SYMBOL
    ( variableDeclaration
    / conditionDeclaration
    / handlerDeclaration
    / cursorDeclaration
    )

variableDeclaration
  = identifierList dataType collate? (DEFAULT_SYMBOL expr)?

conditionDeclaration
  = identifier CONDITION_SYMBOL FOR_SYMBOL spCondition

spCondition
  = ulong_number
  / sqlstate

sqlstate
  = SQLSTATE_SYMBOL VALUE_SYMBOL? textLiteral

handlerDeclaration
  = (CONTINUE_SYMBOL / EXIT_SYMBOL / UNDO_SYMBOL)
    HANDLER_SYMBOL FOR_SYMBOL
    handlerCondition (COMMA_SYMBOL handlerCondition)*
    compoundStatement

handlerCondition
  = spCondition
  / identifier
  / SQLWARNING_SYMBOL
  / notRule FOUND_SYMBOL
  / SQLEXCEPTION_SYMBOL

cursorDeclaration
  = identifier CURSOR_SYMBOL FOR_SYMBOL selectStatement

iterateStatement
  = ITERATE_SYMBOL labelRef

leaveStatement
  = LEAVE_SYMBOL labelRef

getDiagnostics
  = GET_SYMBOL (CURRENT_SYMBOL / &{serverVersion >= 50700} STACKED_SYMBOL)?
    DIAGNOSTICS_SYMBOL
    ( statementInformationItem (COMMA_SYMBOL statementInformationItem)*
    / CONDITION_SYMBOL signalAllowedExpr
      conditionInformationItem (COMMA_SYMBOL conditionInformationItem)*
    )

// Only a limited subset of expr is allowed in SIGNAL/RESIGNAL/CONDITIONS.
signalAllowedExpr
  = literal
  / variable
  / qualifiedIdentifier

statementInformationItem
  = (variable / identifier) EQUAL_OPERATOR (NUMBER_SYMBOL / ROW_COUNT_SYMBOL)

conditionInformationItem
  = (variable / identifier) EQUAL_OPERATOR (signalInformationItemName / RETURNED_SQLSTATE_SYMBOL)

signalInformationItemName
  = CLASS_ORIGIN_SYMBOL
  / SUBCLASS_ORIGIN_SYMBOL
  / CONSTRAINT_CATALOG_SYMBOL
  / CONSTRAINT_SCHEMA_SYMBOL
  / CONSTRAINT_NAME_SYMBOL
  / CATALOG_NAME_SYMBOL
  / SCHEMA_NAME_SYMBOL
  / TABLE_NAME_SYMBOL
  / COLUMN_NAME_SYMBOL
  / CURSOR_NAME_SYMBOL
  / MESSAGE_TEXT_SYMBOL
  / MYSQL_ERRNO_SYMBOL

signalStatement
  = SIGNAL_SYMBOL (identifier / sqlstate) (SET_SYMBOL signalInformationItem (COMMA_SYMBOL signalInformationItem)*)?

resignalStatement
  = RESIGNAL_SYMBOL (identifier / sqlstate)? (SET_SYMBOL signalInformationItem (COMMA_SYMBOL signalInformationItem)*)?

signalInformationItem
  = signalInformationItemName EQUAL_OPERATOR signalAllowedExpr

cursorOpen
  = OPEN_SYMBOL identifier

cursorClose
  = CLOSE_SYMBOL identifier

cursorFetch
  = FETCH_SYMBOL (NEXT_SYMBOL? FROM_SYMBOL)? identifier INTO_SYMBOL identifierList

//----------------- Supplemental rules ---------------------------------------------------------------------------------

// Schedules in CREATE/ALTER EVENT.
schedule
  = AT_SYMBOL expr
  / EVERY_SYMBOL expr interval (STARTS_SYMBOL expr)? (ENDS_SYMBOL expr)?

columnDefinition
  = columnName fieldDefinition checkOrReferences?

checkOrReferences
  = &{serverVersion < 80016} checkConstraint
  / references

checkConstraint
  = CHECK_SYMBOL exprWithParentheses

constraintEnforcement
  = NOT_SYMBOL? ENFORCED_SYMBOL

tableConstraintDef
  = ( KEY_SYMBOL
      / INDEX_SYMBOL
      )
    indexNameAndType? keyListVariants indexOption*
  / FULLTEXT_SYMBOL keyOrIndex? indexName? keyListVariants fulltextIndexOption*
  / SPATIAL_SYMBOL keyOrIndex? indexName? keyListVariants spatialIndexOption*
  / constraintName?
    ( (PRIMARY_SYMBOL KEY_SYMBOL / UNIQUE_SYMBOL keyOrIndex?)
      indexNameAndType? keyListVariants indexOption*
    / FOREIGN_SYMBOL KEY_SYMBOL indexName? keyList references
    / checkConstraint (&{serverVersion >= 80017} constraintEnforcement)?
    )

constraintName
  = CONSTRAINT_SYMBOL identifier?

fieldDefinition
  = dataType
    ( columnAttribute*
    / &{serverVersion >= 50707} collate? (GENERATED_SYMBOL ALWAYS_SYMBOL)?
      AS_SYMBOL exprWithParentheses
      ( VIRTUAL_SYMBOL
      / STORED_SYMBOL
      )?
      ( &{serverVersion < 80000} gcolAttribute*
      / &{serverVersion >= 80000} columnAttribute* // Beginning with 8.0 the full attribute set is supported.
      )
    )

columnAttribute
  = NOT_SYMBOL? nullLiteral
  / &{serverVersion >= 80014} NOT_SYMBOL SECONDARY_SYMBOL
  /  DEFAULT_SYMBOL
    ( signedLiteral
    / NOW_SYMBOL timeFunctionParameters?
    / &{serverVersion >= 80013} exprWithParentheses
    )
  /  ON_SYMBOL UPDATE_SYMBOL NOW_SYMBOL timeFunctionParameters?
  /  AUTO_INCREMENT_SYMBOL
  /  SERIAL_SYMBOL DEFAULT_SYMBOL VALUE_SYMBOL
  / PRIMARY_SYMBOL?  KEY_SYMBOL
  /  UNIQUE_SYMBOL KEY_SYMBOL?
  /  COMMENT_SYMBOL textLiteral
  / collate
  /  COLUMN_FORMAT_SYMBOL columnFormat
  /  STORAGE_SYMBOL storageMedia
  / &{serverVersion >= 80000}  SRID_SYMBOL real_ulonglong_number
  / &{serverVersion >= 80017} constraintName? checkConstraint
  / &{serverVersion >= 80017} constraintEnforcement

columnFormat
  = FIXED_SYMBOL
  / DYNAMIC_SYMBOL
  / DEFAULT_SYMBOL

storageMedia
  = DISK_SYMBOL
  / MEMORY_SYMBOL
  / DEFAULT_SYMBOL

gcolAttribute
  = UNIQUE_SYMBOL KEY_SYMBOL?
  / COMMENT_SYMBOL textString
  / notRule? NULL_SYMBOL
  / PRIMARY_SYMBOL? KEY_SYMBOL

references
  = REFERENCES_SYMBOL tableRef
    identifierListWithParentheses?
    (MATCH_SYMBOL (FULL_SYMBOL / PARTIAL_SYMBOL / SIMPLE_SYMBOL))?
    (
     ((ON_SYMBOL UPDATE_SYMBOL deleteOption)?
      (ON_SYMBOL DELETE_SYMBOL deleteOption)?) / 
     ((ON_SYMBOL DELETE_SYMBOL deleteOption)?
      (ON_SYMBOL UPDATE_SYMBOL deleteOption)?) 
    )?

deleteOption
  = (RESTRICT_SYMBOL / CASCADE_SYMBOL)
  / SET_SYMBOL nullLiteral
  / NO_SYMBOL ACTION_SYMBOL

keyList
  = OPEN_PAR_SYMBOL keyPart (COMMA_SYMBOL keyPart)* CLOSE_PAR_SYMBOL

keyPart
  = identifier fieldLength? direction?

keyListWithExpression
  = OPEN_PAR_SYMBOL keyPartOrExpression (COMMA_SYMBOL keyPartOrExpression)* CLOSE_PAR_SYMBOL

keyPartOrExpression // key_part_with_expression in sql_yacc.yy.
  = keyPart
  / exprWithParentheses direction?

keyListVariants
  = &{serverVersion >= 80013} keyListWithExpression
  / &{serverVersion < 80013} keyList

indexType
  = (BTREE_SYMBOL / RTREE_SYMBOL / HASH_SYMBOL)

indexOption
  = commonIndexOption
  / indexTypeClause

// These options are common for all index types.
commonIndexOption
  = KEY_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? ulong_number
  / COMMENT_SYMBOL textLiteral
  / &{serverVersion >= 80000} visibility

visibility
  = VISIBLE_SYMBOL
  / INVISIBLE_SYMBOL

indexTypeClause
  = (USING_SYMBOL / TYPE_SYMBOL) indexType

fulltextIndexOption
  = commonIndexOption
  / WITH_SYMBOL PARSER_SYMBOL identifier

spatialIndexOption
  = commonIndexOption

dataTypeDefinition // For external use only. Don't reference this in the normal grammar.
  = dataType EOF

dataType // type in sql_yacc.yy
  = ( INT_SYMBOL
      / TINYINT_SYMBOL
      / SMALLINT_SYMBOL
      / MEDIUMINT_SYMBOL
      / BIGINT_SYMBOL
      )
    fieldLength? fieldOptions?
  / (REAL_SYMBOL / DOUBLE_SYMBOL PRECISION_SYMBOL?)
    precision? fieldOptions?
  / ( FLOAT_SYMBOL
      / DECIMAL_SYMBOL
      / NUMERIC_SYMBOL
      / FIXED_SYMBOL
      )
    floatOptions? fieldOptions?
  / BIT_SYMBOL fieldLength?
  / (BOOL_SYMBOL / BOOLEAN_SYMBOL)
  / CHAR_SYMBOL fieldLength? charsetWithOptBinary?
  / nchar fieldLength? BINARY_SYMBOL?
  / BINARY_SYMBOL fieldLength?
  / (CHAR_SYMBOL VARYING_SYMBOL / VARCHAR_SYMBOL)
    fieldLength charsetWithOptBinary?
  / ( NATIONAL_SYMBOL VARCHAR_SYMBOL
    / NVARCHAR_SYMBOL
    / NCHAR_SYMBOL VARCHAR_SYMBOL
    / NATIONAL_SYMBOL CHAR_SYMBOL VARYING_SYMBOL
    / NCHAR_SYMBOL VARYING_SYMBOL
    )
    fieldLength BINARY_SYMBOL?
  / VARBINARY_SYMBOL fieldLength
  / LONG_SYMBOL VARBINARY_SYMBOL
  / LONG_SYMBOL (CHAR_SYMBOL VARYING_SYMBOL / VARCHAR_SYMBOL)? charsetWithOptBinary?
  / YEAR_SYMBOL fieldLength? fieldOptions?
  / DATE_SYMBOL
  / TIME_SYMBOL typeDatetimePrecision?
  / TIMESTAMP_SYMBOL typeDatetimePrecision?
  / DATETIME_SYMBOL typeDatetimePrecision?
  / TINYBLOB_SYMBOL
  / BLOB_SYMBOL fieldLength?
  / (MEDIUMBLOB_SYMBOL / LONGBLOB_SYMBOL)
  / TINYTEXT_SYMBOL charsetWithOptBinary?
  / TEXT_SYMBOL fieldLength? charsetWithOptBinary?
  / MEDIUMTEXT_SYMBOL charsetWithOptBinary?
  / LONGTEXT_SYMBOL charsetWithOptBinary?
  / ENUM_SYMBOL stringList charsetWithOptBinary?
  / SET_SYMBOL stringList charsetWithOptBinary?
  / SERIAL_SYMBOL
  / &{serverVersion >= 50708} JSON_SYMBOL
  / ( GEOMETRY_SYMBOL
      / GEOMETRYCOLLECTION_SYMBOL
      / POINT_SYMBOL
      / MULTIPOINT_SYMBOL
      / LINESTRING_SYMBOL
      / MULTILINESTRING_SYMBOL
      / POLYGON_SYMBOL
      / MULTIPOLYGON_SYMBOL
      )

nchar
  = NCHAR_SYMBOL
  / NATIONAL_SYMBOL CHAR_SYMBOL

realType
  = REAL_SYMBOL
  / DOUBLE_SYMBOL PRECISION_SYMBOL?

fieldLength
  = OPEN_PAR_SYMBOL (real_ulonglong_number / DECIMAL_NUMBER) CLOSE_PAR_SYMBOL

fieldOptions
  = (SIGNED_SYMBOL / UNSIGNED_SYMBOL / ZEROFILL_SYMBOL)+

charsetWithOptBinary
  = ascii
  / unicode
  / BYTE_SYMBOL
  / charset charsetName BINARY_SYMBOL?
  / BINARY_SYMBOL (charset charsetName)?

ascii
  = ASCII_SYMBOL BINARY_SYMBOL?
  / BINARY_SYMBOL ASCII_SYMBOL

unicode
  = UNICODE_SYMBOL BINARY_SYMBOL?
  / BINARY_SYMBOL UNICODE_SYMBOL

wsNumCodepoints
  = OPEN_PAR_SYMBOL real_ulong_number CLOSE_PAR_SYMBOL

typeDatetimePrecision
  = OPEN_PAR_SYMBOL INT_NUMBER CLOSE_PAR_SYMBOL

charsetName
  = textOrIdentifier
  / BINARY_SYMBOL
  / &{serverVersion < 80011} DEFAULT_SYMBOL

collationName
  = textOrIdentifier
  / &{serverVersion < 80011} DEFAULT_SYMBOL
  / &{serverVersion >= 80018} BINARY_SYMBOL

createTableOptions
  = createTableOption (COMMA_SYMBOL? createTableOption)*

createTableOptionsSpaceSeparated
  = createTableOption+

createTableOption // In the order as they appear in the server grammar.
  = ENGINE_SYMBOL EQUAL_OPERATOR? engineRef
  / &{serverVersion >= 80014} SECONDARY_ENGINE_SYMBOL equal? (NULL_SYMBOL / textOrIdentifier)
  / MAX_ROWS_SYMBOL EQUAL_OPERATOR? ulonglong_number
  / MIN_ROWS_SYMBOL EQUAL_OPERATOR? ulonglong_number
  / AVG_ROW_LENGTH_SYMBOL EQUAL_OPERATOR? ulong_number
  / PASSWORD_SYMBOL EQUAL_OPERATOR? textStringLiteral
  / COMMENT_SYMBOL EQUAL_OPERATOR? textStringLiteral
  / &{serverVersion >= 50708} COMPRESSION_SYMBOL EQUAL_OPERATOR? textString
  / &{serverVersion >= 50711} ENCRYPTION_SYMBOL EQUAL_OPERATOR? textString
  / AUTO_INCREMENT_SYMBOL EQUAL_OPERATOR? ulonglong_number
  / PACK_KEYS_SYMBOL EQUAL_OPERATOR? ternaryOption
  / ( STATS_AUTO_RECALC_SYMBOL
      / STATS_PERSISTENT_SYMBOL
      / STATS_SAMPLE_PAGES_SYMBOL
      )
    EQUAL_OPERATOR? ternaryOption
  / (CHECKSUM_SYMBOL / TABLE_CHECKSUM_SYMBOL) EQUAL_OPERATOR? ulong_number
  / DELAY_KEY_WRITE_SYMBOL EQUAL_OPERATOR? ulong_number
  / ROW_FORMAT_SYMBOL EQUAL_OPERATOR?
    format
    = ( DEFAULT_SYMBOL
      / DYNAMIC_SYMBOL
      / FIXED_SYMBOL
      / COMPRESSED_SYMBOL
      / REDUNDANT_SYMBOL
      / COMPACT_SYMBOL
      )
  / UNION_SYMBOL EQUAL_OPERATOR? OPEN_PAR_SYMBOL tableRefList CLOSE_PAR_SYMBOL
  / defaultCharset
  / defaultCollation
  / INSERT_METHOD_SYMBOL EQUAL_OPERATOR?
    method
    = ( NO_SYMBOL
      / FIRST_SYMBOL
      / LAST_SYMBOL
      )
  / DATA_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? textString
  / INDEX_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? textString
  / TABLESPACE_SYMBOL (&{serverVersion >= 50707} EQUAL_OPERATOR?)? identifier
  / STORAGE_SYMBOL (DISK_SYMBOL / MEMORY_SYMBOL)
  / CONNECTION_SYMBOL EQUAL_OPERATOR? textString
  / KEY_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? ulong_number

ternaryOption
  = ulong_number
  / DEFAULT_SYMBOL

defaultCollation
  = DEFAULT_SYMBOL? COLLATE_SYMBOL EQUAL_OPERATOR? collationName

defaultEncryption
  = DEFAULT_SYMBOL? ENCRYPTION_SYMBOL EQUAL_OPERATOR? textStringLiteral

defaultCharset
  = DEFAULT_SYMBOL? charset EQUAL_OPERATOR? charsetName

// Partition rules for CREATE/ALTER TABLE.
partitionClause
  = PARTITION_SYMBOL BY_SYMBOL partitionTypeDef
    (PARTITIONS_SYMBOL real_ulong_number)?
    subPartitions? partitionDefinitions?

partitionTypeDef
  = LINEAR_SYMBOL? KEY_SYMBOL partitionKeyAlgorithm?
    OPEN_PAR_SYMBOL identifierList? CLOSE_PAR_SYMBOL 
  / LINEAR_SYMBOL? HASH_SYMBOL OPEN_PAR_SYMBOL bitExpr CLOSE_PAR_SYMBOL                             
  / (RANGE_SYMBOL / LIST_SYMBOL)
    ( OPEN_PAR_SYMBOL bitExpr CLOSE_PAR_SYMBOL
    / COLUMNS_SYMBOL OPEN_PAR_SYMBOL identifierList? CLOSE_PAR_SYMBOL
    ) 

subPartitions
  = SUBPARTITION_SYMBOL BY_SYMBOL LINEAR_SYMBOL?
    ( HASH_SYMBOL OPEN_PAR_SYMBOL bitExpr CLOSE_PAR_SYMBOL
    / KEY_SYMBOL partitionKeyAlgorithm? identifierListWithParentheses
    )
    (SUBPARTITIONS_SYMBOL real_ulong_number)?

partitionKeyAlgorithm // Actually only 1 and 2 are allowed. Needs a semantic check.
  = &{serverVersion >= 50700} ALGORITHM_SYMBOL EQUAL_OPERATOR real_ulong_number

partitionDefinitions
  = OPEN_PAR_SYMBOL partitionDefinition (COMMA_SYMBOL partitionDefinition)* CLOSE_PAR_SYMBOL

partitionDefinition
  = PARTITION_SYMBOL identifier
    ( VALUES_SYMBOL LESS_SYMBOL THAN_SYMBOL
      ( partitionValueItemListParen
      / MAXVALUE_SYMBOL
      )
    / VALUES_SYMBOL IN_SYMBOL partitionValuesIn
    )?
    partitionOption*
    (OPEN_PAR_SYMBOL subpartitionDefinition (COMMA_SYMBOL subpartitionDefinition)* CLOSE_PAR_SYMBOL)?

partitionValuesIn
  = partitionValueItemListParen
  / OPEN_PAR_SYMBOL
    partitionValueItemListParen (COMMA_SYMBOL partitionValueItemListParen)*
    CLOSE_PAR_SYMBOL

partitionOption
  = TABLESPACE_SYMBOL EQUAL_OPERATOR? identifier
  / STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? engineRef
  / NODEGROUP_SYMBOL EQUAL_OPERATOR? real_ulong_number
  / (MAX_ROWS_SYMBOL / MIN_ROWS_SYMBOL) EQUAL_OPERATOR? real_ulong_number
  / (DATA_SYMBOL / INDEX_SYMBOL) DIRECTORY_SYMBOL EQUAL_OPERATOR? textLiteral
  / COMMENT_SYMBOL EQUAL_OPERATOR? textLiteral

subpartitionDefinition
  = SUBPARTITION_SYMBOL textOrIdentifier partitionOption*

partitionValueItemListParen
  = OPEN_PAR_SYMBOL partitionValueItem (COMMA_SYMBOL partitionValueItem)* CLOSE_PAR_SYMBOL

partitionValueItem
  = bitExpr
  / MAXVALUE_SYMBOL

definerClause
  = DEFINER_SYMBOL EQUAL_OPERATOR user

ifExists
  = IF_SYMBOL EXISTS_SYMBOL

ifNotExists
  = IF_SYMBOL notRule EXISTS_SYMBOL

procedureParameter
  = (IN_SYMBOL / OUT_SYMBOL / INOUT_SYMBOL)? functionParameter

functionParameter
  = parameterName typeWithOptCollate

collate
  = COLLATE_SYMBOL collationName

typeWithOptCollate
  = dataType collate?

schemaIdentifierPair
  = OPEN_PAR_SYMBOL schemaRef COMMA_SYMBOL schemaRef CLOSE_PAR_SYMBOL

viewRefList
  = viewRef (COMMA_SYMBOL viewRef)*

updateList
  = updateElement (COMMA_SYMBOL updateElement)*

updateElement
  = columnRef EQUAL_OPERATOR (expr / DEFAULT_SYMBOL)

charsetClause
  = charset charsetName

charset
  = CHAR_SYMBOL SET_SYMBOL
  / CHARSET_SYMBOL

fieldsClause
  = COLUMNS_SYMBOL fieldTerm+

fieldTerm
  = TERMINATED_SYMBOL BY_SYMBOL textString
  / OPTIONALLY_SYMBOL? ENCLOSED_SYMBOL BY_SYMBOL textString
  / ESCAPED_SYMBOL BY_SYMBOL textString

linesClause
  = LINES_SYMBOL lineTerm+

lineTerm
  = (TERMINATED_SYMBOL / STARTING_SYMBOL) BY_SYMBOL textString

userList
  = user (COMMA_SYMBOL user)*

createUserList
  = createUserEntry (COMMA_SYMBOL createUserEntry)*

alterUserList
  = alterUserEntry (COMMA_SYMBOL alterUserEntry)*

createUserEntry // create_user in sql_yacc.yy
  = user
    ( IDENTIFIED_SYMBOL
      ( BY_SYMBOL
        (&{serverVersion < 80011} PASSWORD_SYMBOL)? textString
      / WITH_SYMBOL textOrIdentifier
        ( AS_SYMBOL textStringHash
        / &{serverVersion >= 50706} BY_SYMBOL textString
        )?
      / &{serverVersion >= 80018}
        (WITH_SYMBOL textOrIdentifier)? BY_SYMBOL RANDOM_SYMBOL PASSWORD_SYMBOL
      )
    )?

alterUserEntry // alter_user in sql_yacc.yy
  = user
    ( IDENTIFIED_SYMBOL
      ( (WITH_SYMBOL textOrIdentifier)?
        BY_SYMBOL textString
        (REPLACE_SYMBOL textString)? retainCurrentPassword?
      / WITH_SYMBOL textOrIdentifier (AS_SYMBOL textStringHash retainCurrentPassword?)?
      )?
    / &{serverVersion >= 80014} discardOldPassword?
    )

retainCurrentPassword
  = RETAIN_SYMBOL CURRENT_SYMBOL PASSWORD_SYMBOL

discardOldPassword
  = DISCARD_SYMBOL OLD_SYMBOL PASSWORD_SYMBOL

replacePassword
  = REPLACE_SYMBOL textString

userIdentifierOrText
  = textOrIdentifier (AT_SIGN_SYMBOL textOrIdentifier / AT_TEXT_SUFFIX)?

user
  = userIdentifierOrText
  / CURRENT_USER_SYMBOL parentheses?

likeClause
  = LIKE_SYMBOL textStringLiteral

likeOrWhere // opt_wild_or_where in sql_yacc.yy
  = likeClause
  / whereClause

onlineOption
  = ONLINE_SYMBOL
  / OFFLINE_SYMBOL

noWriteToBinLog
  = LOCAL_SYMBOL
  / NO_WRITE_TO_BINLOG_SYMBOL

usePartition
  = &{serverVersion >= 50602} PARTITION_SYMBOL identifierListWithParentheses

//----------------- Object names and references ------------------------------------------------------------------------

// For each object we have at least 2 rules here:
// 1) The name when creating that object.
// 2) The name when used to reference it from other rules.
//
// Sometimes we need additional reference rules with different form, depending on the place such a reference is used.

// A name for a field (column/index). Can be qualified with the current schema + table (although it's not a reference).
fieldIdentifier
  = dotIdentifier
  / qualifiedIdentifier dotIdentifier?

columnName
  = // With server 8.0 this became a simple identifier.
    &{serverVersion >= 80000} identifier
  / &{serverVersion < 80000} fieldIdentifier

// A reference to a column of the object we are working on.
columnInternalRef
  = identifier

columnInternalRefList // column_list (+ parentheses) + opt_derived_column_list in sql_yacc.yy
  = OPEN_PAR_SYMBOL columnInternalRef (COMMA_SYMBOL columnInternalRef)* CLOSE_PAR_SYMBOL

columnRef // A field identifier that can reference any schema/table.
  = fieldIdentifier

insertIdentifier
  = columnRef
  / tableWild

indexName
  = identifier

indexRef // Always internal reference. Still all qualification variations are accepted.
  = fieldIdentifier

tableWild
  = identifier DOT_SYMBOL (identifier DOT_SYMBOL)? MULT_OPERATOR

schemaName
  = identifier

schemaRef
  = identifier

procedureName
  = qualifiedIdentifier

procedureRef
  = qualifiedIdentifier

functionName
  = qualifiedIdentifier

functionRef
  = qualifiedIdentifier

triggerName
  = qualifiedIdentifier

triggerRef
  = qualifiedIdentifier

viewName
  = qualifiedIdentifier
  / dotIdentifier

viewRef
  = qualifiedIdentifier
  / dotIdentifier

tablespaceName
  = identifier

tablespaceRef
  = identifier

logfileGroupName
  = identifier

logfileGroupRef
  = identifier

eventName
  = qualifiedIdentifier

eventRef
  = qualifiedIdentifier

udfName // UDFs are referenced at the same places as any other function. So, no dedicated *_ref here.
  = identifier

serverName
  = textOrIdentifier

serverRef
  = textOrIdentifier

engineRef
  = textOrIdentifier

tableName
  = qualifiedIdentifier
  / dotIdentifier

filterTableRef // Always qualified.
  = schemaRef dotIdentifier

tableRefWithWildcard
  = identifier (DOT_SYMBOL MULT_OPERATOR / dotIdentifier (DOT_SYMBOL MULT_OPERATOR)?)?

tableRef
  = qualifiedIdentifier
  / dotIdentifier

tableRefList
  = tableRef (COMMA_SYMBOL tableRef)*

tableAliasRefList
  = tableRefWithWildcard (COMMA_SYMBOL tableRefWithWildcard)*

parameterName
  = identifier

labelIdentifier
  = pureIdentifier
  / labelKeyword

labelRef
  = labelIdentifier

roleIdentifier
  = pureIdentifier
  / roleKeyword

roleRef
  = roleIdentifier

pluginRef
  = identifier

componentRef
  = textStringLiteral

resourceGroupRef
  = identifier

windowName
  = identifier

//----------------- Common basic rules ---------------------------------------------------------------------------------

// Identifiers excluding keywords (except if they are quoted). IDENT_sys in sql_yacc.yy.
pureIdentifier
  = (IDENTIFIER / BACK_TICK_QUOTED_ID)
  / &{serverInfo.isSqlModeActive(serverInfo.ANSI_QUOTES)} DOUBLE_QUOTED_TEXT

// Identifiers including a certain set of keywords, which are allowed also if not quoted.
// ident in sql_yacc.yy
identifier
  = pureIdentifier
  / identifierKeyword

identifierList // ident_string_list in sql_yacc.yy.
  = identifier (COMMA_SYMBOL identifier)*

identifierListWithParentheses
  = OPEN_PAR_SYMBOL identifierList CLOSE_PAR_SYMBOL

qualifiedIdentifier
  = identifier dotIdentifier?

simpleIdentifier // simple_ident + simple_ident_q
  = identifier (dotIdentifier dotIdentifier?)?
  / &{serverVersion < 80000} dotIdentifier dotIdentifier

// This rule encapsulates the frequently used dot + identifier sequence, which also requires a special
// treatment in the lexer. See there in the DOT_IDENTIFIER rule.
dotIdentifier
  = DOT_SYMBOL identifier

ulong_number
  = INT_NUMBER
  / HEX_NUMBER
  / LONG_NUMBER
  / ULONGLONG_NUMBER
  / DECIMAL_NUMBER
  / FLOAT_NUMBER

real_ulong_number
  = INT_NUMBER
  / HEX_NUMBER
  / LONG_NUMBER
  / ULONGLONG_NUMBER

ulonglong_number
  = INT_NUMBER
  / LONG_NUMBER
  / ULONGLONG_NUMBER
  / DECIMAL_NUMBER
  / FLOAT_NUMBER

real_ulonglong_number
  = INT_NUMBER
  / &{serverVersion >= 80017} HEX_NUMBER
  / ULONGLONG_NUMBER
  / LONG_NUMBER

literal
  = textLiteral
  / numLiteral
  / temporalLiteral
  / nullLiteral
  / boolLiteral
  / UNDERSCORE_CHARSET? (HEX_NUMBER / BIN_NUMBER)

signedLiteral
  = literal
  / PLUS_OPERATOR ulong_number
  / MINUS_OPERATOR ulong_number

stringList
  = OPEN_PAR_SYMBOL textString (COMMA_SYMBOL textString)* CLOSE_PAR_SYMBOL

// TEXT_STRING_sys + TEXT_STRING_literal + TEXT_STRING_filesystem + TEXT_STRING + TEXT_STRING_password +
// TEXT_STRING_validated in sql_yacc.yy.
textStringLiteral
  =  SINGLE_QUOTED_TEXT
/*  / {!lexer.isSqlModeActive(MySQLBaseLexer.ANSI_QUOTES)}  DOUBLE_QUOTED_TEXT */

textString
  = textStringLiteral
  / HEX_NUMBER
  / BIN_NUMBER

textStringHash
  = textStringLiteral
  / &{serverVersion >= 80017} HEX_NUMBER

textLiteral
  = (UNDERSCORE_CHARSET? textStringLiteral / NCHAR_TEXT) textStringLiteral*

// A special variant of a text string that must not contain a linebreak (TEXT_STRING_sys_nonewline in sql_yacc.yy).
// Check validity in semantic phase.
textStringNoLinebreak
  = textStringLiteral

textStringLiteralList
  = textStringLiteral (COMMA_SYMBOL textStringLiteral)*

numLiteral
  = INT_NUMBER
  / LONG_NUMBER
  / ULONGLONG_NUMBER
  / DECIMAL_NUMBER
  / FLOAT_NUMBER

boolLiteral
  = TRUE_SYMBOL
  / FALSE_SYMBOL

nullLiteral // In sql_yacc.cc both 'NULL' and '\N' are mapped to NULL_SYM (which is our nullLiteral).
  = NULL_SYMBOL
  / NULL2_SYMBOL

temporalLiteral
  = DATE_SYMBOL SINGLE_QUOTED_TEXT
  / TIME_SYMBOL SINGLE_QUOTED_TEXT
  / TIMESTAMP_SYMBOL SINGLE_QUOTED_TEXT

floatOptions
  = fieldLength
  / precision

standardFloatOptions
  = precision

precision
  = OPEN_PAR_SYMBOL INT_NUMBER COMMA_SYMBOL INT_NUMBER CLOSE_PAR_SYMBOL

textOrIdentifier
  = identifier
  / textStringLiteral

lValueIdentifier
  = pureIdentifier
  / lValueKeyword

roleIdentifierOrText
  = roleIdentifier
  / textStringLiteral

sizeNumber
  = real_ulonglong_number
  / pureIdentifier // Something like 10G. Semantic check needed for validity.

parentheses
  = OPEN_PAR_SYMBOL CLOSE_PAR_SYMBOL

equal
  = EQUAL_OPERATOR
  / ASSIGN_OPERATOR

// PERSIST and PERSIST_ONLY are conditionally handled in the lexer. Hence no predicate required here.
optionType
  = PERSIST_SYMBOL
  / PERSIST_ONLY_SYMBOL
  / GLOBAL_SYMBOL
  / LOCAL_SYMBOL
  / SESSION_SYMBOL

varIdentType
  = GLOBAL_SYMBOL DOT_SYMBOL
  / LOCAL_SYMBOL DOT_SYMBOL
  / SESSION_SYMBOL DOT_SYMBOL

setVarIdentType
  = PERSIST_SYMBOL DOT_SYMBOL
  / PERSIST_ONLY_SYMBOL DOT_SYMBOL
  / GLOBAL_SYMBOL DOT_SYMBOL
  / LOCAL_SYMBOL DOT_SYMBOL
  / SESSION_SYMBOL DOT_SYMBOL

notRule
  = NOT_SYMBOL
  / NOT2_SYMBOL // A NOT with a different (higher) operator precedence.

not2Rule
  = LOGICAL_NOT_OPERATOR
  / NOT2_SYMBOL

// None of the microsecond variants can be used in schedules (e.g. events).
interval
  = intervalTimeStamp
  / ( SECOND_MICROSECOND_SYMBOL
    / MINUTE_MICROSECOND_SYMBOL
    / MINUTE_SECOND_SYMBOL
    / HOUR_MICROSECOND_SYMBOL
    / HOUR_SECOND_SYMBOL
    / HOUR_MINUTE_SYMBOL
    / DAY_MICROSECOND_SYMBOL
    / DAY_SECOND_SYMBOL
    / DAY_MINUTE_SYMBOL
    / DAY_HOUR_SYMBOL
    / YEAR_MONTH_SYMBOL
    )

// Support for SQL_TSI_* units is added by mapping those to tokens without SQL_TSI_ prefix.
intervalTimeStamp
  = MICROSECOND_SYMBOL
  / SECOND_SYMBOL
  / MINUTE_SYMBOL
  / HOUR_SYMBOL
  / DAY_SYMBOL
  / WEEK_SYMBOL
  / MONTH_SYMBOL
  / QUARTER_SYMBOL
  / YEAR_SYMBOL

// Note: rules for non-reserved keywords have changed significantly with MySQL 8.0.17, which make their
//       version dependent handling complicated.
//       Comments for keyword rules are taken over directly from the server grammar, but usually don't apply here
//       since we don't have something like shift/reduce conflicts in ANTLR4 (which those ugly rules try to overcome).

// Non-reserved keywords are allowed as unquoted identifiers in general.
//
// OTOH, in a few particular cases statement-specific rules are used
// instead of `ident_keyword` to avoid grammar ambiguities:
//
//  * `label_keyword` for SP label names
//  * `role_keyword` for role names
//  * `lvalue_keyword` for variable prefixes and names in left sides of
//                     assignments in SET statements
//
// Normally, new non-reserved words should be added to the
// the rule `ident_keywords_unambiguous`. If they cause grammar conflicts, try
// one of `ident_keywords_ambiguous_...` rules instead.
identifierKeyword
  = &{serverVersion < 80017}
    ( labelKeyword
    / roleOrIdentifierKeyword
    / EXECUTE_SYMBOL
    / &{serverVersion >= 50709} SHUTDOWN_SYMBOL // Previously allowed as SP label as well.
    / &{serverVersion >= 80011} RESTART_SYMBOL
    )
  / ( identifierKeywordsUnambiguous
    / identifierKeywordsAmbiguous1RolesAndLabels
    / identifierKeywordsAmbiguous2Labels
    / identifierKeywordsAmbiguous3Roles
    / identifierKeywordsAmbiguous4SystemVariables
    )

// These non-reserved words cannot be used as role names and SP label names:
identifierKeywordsAmbiguous1RolesAndLabels
  = EXECUTE_SYMBOL
  / RESTART_SYMBOL
  / SHUTDOWN_SYMBOL

// These non-reserved keywords cannot be used as unquoted SP label names:
identifierKeywordsAmbiguous2Labels
  = ASCII_SYMBOL
  / BEGIN_SYMBOL
  / BYTE_SYMBOL
  / CACHE_SYMBOL
  / CHARSET_SYMBOL
  / CHECKSUM_SYMBOL
  / CLONE_SYMBOL
  / COMMENT_SYMBOL
  / COMMIT_SYMBOL
  / CONTAINS_SYMBOL
  / DEALLOCATE_SYMBOL
  / DO_SYMBOL
  / END_SYMBOL
  / FLUSH_SYMBOL
  / FOLLOWS_SYMBOL
  / HANDLER_SYMBOL
  / HELP_SYMBOL
  / IMPORT_SYMBOL
  / INSTALL_SYMBOL
  / LANGUAGE_SYMBOL
  / NO_SYMBOL
  / PRECEDES_SYMBOL
  / PREPARE_SYMBOL
  / REPAIR_SYMBOL
  / RESET_SYMBOL
  / ROLLBACK_SYMBOL
  / SAVEPOINT_SYMBOL
  / SIGNED_SYMBOL
  / SLAVE_SYMBOL
  / START_SYMBOL
  / STOP_SYMBOL
  / TRUNCATE_SYMBOL
  / UNICODE_SYMBOL
  / UNINSTALL_SYMBOL
  / XA_SYMBOL

// Keywords that we allow for labels in SPs in the unquoted form.
// Any keyword that is allowed to begin a statement or routine characteristics
// must be in `ident_keywords_ambiguous_2_labels` above, otherwise
// we get (harmful) shift/reduce conflicts.
//
// Not allowed:
//
//   ident_keywords_ambiguous_1_roles_and_labels
//   ident_keywords_ambiguous_2_labels
labelKeyword
  = &{serverVersion < 80017}
    ( roleOrLabelKeyword
    / EVENT_SYMBOL
    / FILE_SYMBOL
    / NONE_SYMBOL
    / PROCESS_SYMBOL
    / PROXY_SYMBOL
    / RELOAD_SYMBOL
    / REPLICATION_SYMBOL
    / RESOURCE_SYMBOL // Conditionally set in the lexer.
    / SUPER_SYMBOL
    )
  / ( identifierKeywordsUnambiguous
    / identifierKeywordsAmbiguous3Roles
    / identifierKeywordsAmbiguous4SystemVariables
    )

// These non-reserved keywords cannot be used as unquoted role names:
identifierKeywordsAmbiguous3Roles
  = EVENT_SYMBOL
  / FILE_SYMBOL
  / NONE_SYMBOL
  / PROCESS_SYMBOL
  / PROXY_SYMBOL
  / RELOAD_SYMBOL
  / REPLICATION_SYMBOL
  / RESOURCE_SYMBOL
  / SUPER_SYMBOL

// These are the non-reserved keywords which may be used for unquoted
// identifiers everywhere without introducing grammar conflicts:
identifierKeywordsUnambiguous
  = ( ACTION_SYMBOL
    / ACCOUNT_SYMBOL
    / ACTIVE_SYMBOL
    / ADDDATE_SYMBOL
    / ADMIN_SYMBOL
    / AFTER_SYMBOL
    / AGAINST_SYMBOL
    / AGGREGATE_SYMBOL
    / ALGORITHM_SYMBOL
    / ALWAYS_SYMBOL
    / ANY_SYMBOL
    / AT_SYMBOL
    / AUTOEXTEND_SIZE_SYMBOL
    / AUTO_INCREMENT_SYMBOL
    / AVG_ROW_LENGTH_SYMBOL
    / AVG_SYMBOL
    / BACKUP_SYMBOL
    / BINLOG_SYMBOL
    / BIT_SYMBOL
    / BLOCK_SYMBOL
    / BOOLEAN_SYMBOL
    / BOOL_SYMBOL
    / BTREE_SYMBOL
    / BUCKETS_SYMBOL
    / CASCADED_SYMBOL
    / CATALOG_NAME_SYMBOL
    / CHAIN_SYMBOL
    / CHANGED_SYMBOL
    / CHANNEL_SYMBOL
    / CIPHER_SYMBOL
    / CLASS_ORIGIN_SYMBOL
    / CLIENT_SYMBOL
    / CLOSE_SYMBOL
    / COALESCE_SYMBOL
    / CODE_SYMBOL
    / COLLATION_SYMBOL
    / COLUMNS_SYMBOL
    / COLUMN_FORMAT_SYMBOL
    / COLUMN_NAME_SYMBOL
    / COMMITTED_SYMBOL
    / COMPACT_SYMBOL
    / COMPLETION_SYMBOL
    / COMPONENT_SYMBOL
    / COMPRESSED_SYMBOL
    / COMPRESSION_SYMBOL
    / CONCURRENT_SYMBOL
    / CONNECTION_SYMBOL
    / CONSISTENT_SYMBOL
    / CONSTRAINT_CATALOG_SYMBOL
    / CONSTRAINT_NAME_SYMBOL
    / CONSTRAINT_SCHEMA_SYMBOL
    / CONTEXT_SYMBOL
    / CPU_SYMBOL
    / CURRENT_SYMBOL // not reserved in MySQL per WL#2111 specification
    / CURSOR_NAME_SYMBOL
    / DATAFILE_SYMBOL
    / DATA_SYMBOL
    / DATETIME_SYMBOL
    / DATE_SYMBOL
    / DAY_SYMBOL
    / DEFAULT_AUTH_SYMBOL
    / DEFINER_SYMBOL
    / DEFINITION_SYMBOL
    / DELAY_KEY_WRITE_SYMBOL
    / DESCRIPTION_SYMBOL
    / DIAGNOSTICS_SYMBOL
    / DIRECTORY_SYMBOL
    / DISABLE_SYMBOL
    / DISCARD_SYMBOL
    / DISK_SYMBOL
    / DUMPFILE_SYMBOL
    / DUPLICATE_SYMBOL
    / DYNAMIC_SYMBOL
    / ENABLE_SYMBOL
    / ENCRYPTION_SYMBOL
    / ENDS_SYMBOL
    / ENFORCED_SYMBOL
    / ENGINES_SYMBOL
    / ENGINE_SYMBOL
    / ENUM_SYMBOL
    / ERRORS_SYMBOL
    / ERROR_SYMBOL
    / ESCAPE_SYMBOL
    / EVENTS_SYMBOL
    / EVERY_SYMBOL
    / EXCHANGE_SYMBOL
    / EXCLUDE_SYMBOL
    / EXPANSION_SYMBOL
    / EXPIRE_SYMBOL
    / EXPORT_SYMBOL
    / EXTENDED_SYMBOL
    / EXTENT_SIZE_SYMBOL
    / FAST_SYMBOL
    / FAULTS_SYMBOL
    / FILE_BLOCK_SIZE_SYMBOL
    / FILTER_SYMBOL
    / FIRST_SYMBOL
    / FIXED_SYMBOL
    / FOLLOWING_SYMBOL
    / FORMAT_SYMBOL
    / FOUND_SYMBOL
    / FULL_SYMBOL
    / GENERAL_SYMBOL
    / GEOMETRYCOLLECTION_SYMBOL
    / GEOMETRY_SYMBOL
    / GET_FORMAT_SYMBOL
    / GET_MASTER_PUBLIC_KEY_SYMBOL
    / GRANTS_SYMBOL
    / GROUP_REPLICATION_SYMBOL
    / HASH_SYMBOL
    / HISTOGRAM_SYMBOL
    / HISTORY_SYMBOL
    / HOSTS_SYMBOL
    / HOST_SYMBOL
    / HOUR_SYMBOL
    / IDENTIFIED_SYMBOL
    / IGNORE_SERVER_IDS_SYMBOL
    / INACTIVE_SYMBOL
    / INDEXES_SYMBOL
    / INITIAL_SIZE_SYMBOL
    / INSERT_METHOD_SYMBOL
    / INSTANCE_SYMBOL
    / INVISIBLE_SYMBOL
    / INVOKER_SYMBOL
    / IO_SYMBOL
    / IPC_SYMBOL
    / ISOLATION_SYMBOL
    / ISSUER_SYMBOL
    / JSON_SYMBOL
    / KEY_BLOCK_SIZE_SYMBOL
    / LAST_SYMBOL
    / LEAVES_SYMBOL
    / LESS_SYMBOL
    / LEVEL_SYMBOL
    / LINESTRING_SYMBOL
    / LIST_SYMBOL
    / LOCKED_SYMBOL
    / LOCKS_SYMBOL
    / LOGFILE_SYMBOL
    / LOGS_SYMBOL
    / MASTER_AUTO_POSITION_SYMBOL
    / MASTER_COMPRESSION_ALGORITHM_SYMBOL
    / MASTER_CONNECT_RETRY_SYMBOL
    / MASTER_DELAY_SYMBOL
    / MASTER_HEARTBEAT_PERIOD_SYMBOL
    / MASTER_HOST_SYMBOL
    / NETWORK_NAMESPACE_SYMBOL
    / MASTER_LOG_FILE_SYMBOL
    / MASTER_LOG_POS_SYMBOL
    / MASTER_PASSWORD_SYMBOL
    / MASTER_PORT_SYMBOL
    / MASTER_PUBLIC_KEY_PATH_SYMBOL
    / MASTER_RETRY_COUNT_SYMBOL
    / MASTER_SERVER_ID_SYMBOL
    / MASTER_SSL_CAPATH_SYMBOL
    / MASTER_SSL_CA_SYMBOL
    / MASTER_SSL_CERT_SYMBOL
    / MASTER_SSL_CIPHER_SYMBOL
    / MASTER_SSL_CRLPATH_SYMBOL
    / MASTER_SSL_CRL_SYMBOL
    / MASTER_SSL_KEY_SYMBOL
    / MASTER_SSL_SYMBOL
    / MASTER_SYMBOL
    / MASTER_TLS_CIPHERSUITES_SYMBOL
    / MASTER_TLS_VERSION_SYMBOL
    / MASTER_USER_SYMBOL
    / MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL
    / MAX_CONNECTIONS_PER_HOUR_SYMBOL
    / MAX_QUERIES_PER_HOUR_SYMBOL
    / MAX_ROWS_SYMBOL
    / MAX_SIZE_SYMBOL
    / MAX_UPDATES_PER_HOUR_SYMBOL
    / MAX_USER_CONNECTIONS_SYMBOL
    / MEDIUM_SYMBOL
    / MEMORY_SYMBOL
    / MERGE_SYMBOL
    / MESSAGE_TEXT_SYMBOL
    / MICROSECOND_SYMBOL
    / MIGRATE_SYMBOL
    / MINUTE_SYMBOL
    / MIN_ROWS_SYMBOL
    / MODE_SYMBOL
    / MODIFY_SYMBOL
    / MONTH_SYMBOL
    / MULTILINESTRING_SYMBOL
    / MULTIPOINT_SYMBOL
    / MULTIPOLYGON_SYMBOL
    / MUTEX_SYMBOL
    / MYSQL_ERRNO_SYMBOL
    / NAMES_SYMBOL
    / NAME_SYMBOL
    / NATIONAL_SYMBOL
    / NCHAR_SYMBOL
    / NDBCLUSTER_SYMBOL
    / NESTED_SYMBOL
    / NEVER_SYMBOL
    / NEW_SYMBOL
    / NEXT_SYMBOL
    / NODEGROUP_SYMBOL
    / NOWAIT_SYMBOL
    / NO_WAIT_SYMBOL
    / NULLS_SYMBOL
    / NUMBER_SYMBOL
    / NVARCHAR_SYMBOL
    / OFFSET_SYMBOL
    / OJ_SYMBOL
    / OLD_SYMBOL
    / ONE_SYMBOL
    / ONLY_SYMBOL
    / OPEN_SYMBOL
    / OPTIONAL_SYMBOL
    / OPTIONS_SYMBOL
    / ORDINALITY_SYMBOL
    / ORGANIZATION_SYMBOL
    / OTHERS_SYMBOL
    / OWNER_SYMBOL
    / PACK_KEYS_SYMBOL
    / PAGE_SYMBOL
    / PARSER_SYMBOL
    / PARTIAL_SYMBOL
    / PARTITIONING_SYMBOL
    / PARTITIONS_SYMBOL
    / PASSWORD_SYMBOL
    / PATH_SYMBOL
    / PHASE_SYMBOL
    / PLUGINS_SYMBOL
    / PLUGIN_DIR_SYMBOL
    / PLUGIN_SYMBOL
    / POINT_SYMBOL
    / POLYGON_SYMBOL
    / PORT_SYMBOL
    / PRECEDING_SYMBOL
    / PRESERVE_SYMBOL
    / PREV_SYMBOL
    / PRIVILEGES_SYMBOL
    / PRIVILEGE_CHECKS_USER_SYMBOL
    / PROCESSLIST_SYMBOL
    / PROFILES_SYMBOL
    / PROFILE_SYMBOL
    / QUARTER_SYMBOL
    / QUERY_SYMBOL
    / QUICK_SYMBOL
    / READ_ONLY_SYMBOL
    / REBUILD_SYMBOL
    / RECOVER_SYMBOL
    / REDO_BUFFER_SIZE_SYMBOL
    / REDUNDANT_SYMBOL
    / REFERENCE_SYMBOL
    / RELAY_SYMBOL
    / RELAYLOG_SYMBOL
    / RELAY_LOG_FILE_SYMBOL
    / RELAY_LOG_POS_SYMBOL
    / RELAY_THREAD_SYMBOL
    / REMOVE_SYMBOL
    / REORGANIZE_SYMBOL
    / REPEATABLE_SYMBOL
    / REPLICATE_DO_DB_SYMBOL
    / REPLICATE_DO_TABLE_SYMBOL
    / REPLICATE_IGNORE_DB_SYMBOL
    / REPLICATE_IGNORE_TABLE_SYMBOL
    / REPLICATE_REWRITE_DB_SYMBOL
    / REPLICATE_WILD_DO_TABLE_SYMBOL
    / REPLICATE_WILD_IGNORE_TABLE_SYMBOL
    / USER_RESOURCES_SYMBOL
    / RESPECT_SYMBOL
    / RESTORE_SYMBOL
    / RESUME_SYMBOL
    / RETAIN_SYMBOL
    / RETURNED_SQLSTATE_SYMBOL
    / RETURNS_SYMBOL
    / REUSE_SYMBOL
    / REVERSE_SYMBOL
    / ROLE_SYMBOL
    / ROLLUP_SYMBOL
    / ROTATE_SYMBOL
    / ROUTINE_SYMBOL
    / ROW_COUNT_SYMBOL
    / ROW_FORMAT_SYMBOL
    / RTREE_SYMBOL
    / SCHEDULE_SYMBOL
    / SCHEMA_NAME_SYMBOL
    / SECONDARY_ENGINE_SYMBOL
    / SECONDARY_LOAD_SYMBOL
    / SECONDARY_SYMBOL
    / SECONDARY_UNLOAD_SYMBOL
    / SECOND_SYMBOL
    / SECURITY_SYMBOL
    / SERIALIZABLE_SYMBOL
    / SERIAL_SYMBOL
    / SERVER_SYMBOL
    / SHARE_SYMBOL
    / SIMPLE_SYMBOL
    / SKIP_SYMBOL
    / SLOW_SYMBOL
    / SNAPSHOT_SYMBOL
    / SOUNDS_SYMBOL
    / SOURCE_SYMBOL
    / SQL_AFTER_GTIDS_SYMBOL
    / SQL_AFTER_MTS_GAPS_SYMBOL
    / SQL_BEFORE_GTIDS_SYMBOL
    / SQL_BIG_RESULT_SYMBOL
    / SQL_BUFFER_RESULT_SYMBOL
    / SQL_CALC_FOUND_ROWS_SYMBOL
    / SQL_CACHE_SYMBOL
    / SQL_NO_CACHE_SYMBOL
    / SQL_SMALL_RESULT_SYMBOL
    / SQL_THREAD_SYMBOL
    / SRID_SYMBOL
    / STACKED_SYMBOL
    / STARTS_SYMBOL
    / STATS_AUTO_RECALC_SYMBOL
    / STATS_PERSISTENT_SYMBOL
    / STATS_SAMPLE_PAGES_SYMBOL
    / STATUS_SYMBOL
    / STORAGE_SYMBOL
    / STORED_SYMBOL
    / STRAIGHT_JOIN_SYMBOL
    / STREAM_SYMBOL
    / STRING_SYMBOL
    / SUBCLASS_ORIGIN_SYMBOL
    / SUBDATE_SYMBOL
    / SUBJECT_SYMBOL
    / SUBPARTITIONS_SYMBOL
    / SUBPARTITION_SYMBOL
    / SUSPEND_SYMBOL
    / SWAPS_SYMBOL
    / SWITCHES_SYMBOL
    / TABLES_SYMBOL
    / TABLESPACE_SYMBOL
    / TABLE_CHECKSUM_SYMBOL
    / TABLE_NAME_SYMBOL
    / TEMPORARY_SYMBOL
    / TEMPTABLE_SYMBOL
    / TERMINATED_SYMBOL
    / TEXT_SYMBOL
    / THAN_SYMBOL
    / THREAD_PRIORITY_SYMBOL
    / TIES_SYMBOL
    / TIMESTAMP_ADD_SYMBOL
    / TIMESTAMP_DIFF_SYMBOL
    / TIMESTAMP_SYMBOL
    / TIME_SYMBOL
    / TRANSACTION_SYMBOL
    / TRIGGERS_SYMBOL
    / TYPES_SYMBOL
    / TYPE_SYMBOL
    / UNBOUNDED_SYMBOL
    / UNCOMMITTED_SYMBOL
    / UNDEFINED_SYMBOL
    / UNDOFILE_SYMBOL
    / UNDO_BUFFER_SIZE_SYMBOL
    / UNKNOWN_SYMBOL
    / UNTIL_SYMBOL
    / UPGRADE_SYMBOL
    / USER_SYMBOL
    / USE_FRM_SYMBOL
    / VALIDATION_SYMBOL
    / VALUE_SYMBOL
    / VALUES_SYMBOL
    / VARBINARY_SYMBOL
    / VARCHAR_SYMBOL
    / VARIABLES_SYMBOL
    / VARIANCE_SYMBOL
    / VARYING_SYMBOL
    / VAR_POP_SYMBOL
    / VAR_SAMP_SYMBOL
    / VCPU_SYMBOL
    / VIEW_SYMBOL
    / VIRTUAL_SYMBOL
    / VISIBLE_SYMBOL
    / WAIT_SYMBOL
    / WARNINGS_SYMBOL
    / WEEK_SYMBOL
    / WEIGHT_STRING_SYMBOL
    / WHEN_SYMBOL
    / WHERE_SYMBOL
    / WHILE_SYMBOL
    / WINDOW_SYMBOL
    / WITH_SYMBOL
    / WITHOUT_SYMBOL
    / WORK_SYMBOL
    / WRAPPER_SYMBOL
    / WRITE_SYMBOL
    / XA_SYMBOL
    / X509_SYMBOL
    / XID_SYMBOL
    / XML_SYMBOL
    / XOR_SYMBOL
    / YEAR_SYMBOL
    / YEAR_MONTH_SYMBOL
    / ZEROFILL_SYMBOL
    )
  / &{serverVersion >= 80019}
    ( ARRAY_SYMBOL
    / ARRAY_SYMBOL
    / FAILED_LOGIN_ATTEMPTS_SYMBOL
    / MASTER_COMPRESSION_ALGORITHM_SYMBOL
    / MASTER_TLS_CIPHERSUITES_SYMBOL
    / MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL
    / MEMBER_SYMBOL
    / OFF_SYMBOL
    / PASSWORD_LOCK_TIME_SYMBOL
    / PRIVILEGE_CHECKS_USER_SYMBOL
    / RANDOM_SYMBOL
    / REQUIRE_ROW_FORMAT_SYMBOL
    / REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYMBOL
    / STREAM_SYMBOL
    / TIMESTAMP_SYMBOL
    / TIME_SYMBOL)

roleKeyword = (roleOrLabelKeyword / roleOrIdentifierKeyword) 
  / (identifierKeywordsUnambiguous 
  / identifierKeywordsAmbiguous2Labels 
  / identifierKeywordsAmbiguous4SystemVariables)

lValueKeyword = identifierKeywordsUnambiguous 
  / identifierKeywordsAmbiguous1RolesAndLabels 
  / identifierKeywordsAmbiguous2Labels 
  / identifierKeywordsAmbiguous3Roles

identifierKeywordsAmbiguous4SystemVariables = GLOBAL_SYMBOL 
  / LOCAL_SYMBOL 
  / PERSIST_SYMBOL 
  / PERSIST_ONLY_SYMBOL 
  / SESSION_SYMBOL

roleOrIdentifierKeyword = (ACCOUNT_SYMBOL 
  / ASCII_SYMBOL 
  / ALWAYS_SYMBOL 
  / BACKUP_SYMBOL 
  / BEGIN_SYMBOL 
  / BYTE_SYMBOL 
  / CACHE_SYMBOL 
  / CHARSET_SYMBOL 
  / CHECKSUM_SYMBOL 
  / CLONE_SYMBOL 
  / CLOSE_SYMBOL 
  / COMMENT_SYMBOL 
  / COMMIT_SYMBOL 
  / CONTAINS_SYMBOL 
  / DEALLOCATE_SYMBOL 
  / DO_SYMBOL 
  / END_SYMBOL 
  / FLUSH_SYMBOL 
  / FOLLOWS_SYMBOL 
  / FORMAT_SYMBOL 
  / GROUP_REPLICATION_SYMBOL 
  / HANDLER_SYMBOL 
  / HELP_SYMBOL 
  / HOST_SYMBOL 
  / INSTALL_SYMBOL 
  / INVISIBLE_SYMBOL 
  / LANGUAGE_SYMBOL 
  / NO_SYMBOL 
  / OPEN_SYMBOL 
  / OPTIONS_SYMBOL 
  / OWNER_SYMBOL 
  / PARSER_SYMBOL 
  / PARTITION_SYMBOL 
  / PORT_SYMBOL 
  / PRECEDES_SYMBOL 
  / PREPARE_SYMBOL 
  / REMOVE_SYMBOL 
  / REPAIR_SYMBOL 
  / RESET_SYMBOL 
  / RESTORE_SYMBOL 
  / ROLE_SYMBOL 
  / ROLLBACK_SYMBOL 
  / SAVEPOINT_SYMBOL 
  / SECONDARY_SYMBOL 
  / SECONDARY_ENGINE_SYMBOL 
  / SECONDARY_LOAD_SYMBOL 
  / SECONDARY_UNLOAD_SYMBOL 
  / SECURITY_SYMBOL 
  / SERVER_SYMBOL 
  / SIGNED_SYMBOL 
  / SOCKET_SYMBOL 
  / SLAVE_SYMBOL 
  / SONAME_SYMBOL 
  / START_SYMBOL 
  / STOP_SYMBOL 
  / TRUNCATE_SYMBOL 
  / UNICODE_SYMBOL 
  / UNINSTALL_SYMBOL 
  / UPGRADE_SYMBOL 
  / VISIBLE_SYMBOL 
  / WRAPPER_SYMBOL 
  / XA_SYMBOL) 
  / SHUTDOWN_SYMBOL 
  / IMPORT_SYMBOL

roleOrLabelKeyword = (ACTION_SYMBOL 
  / ACTIVE_SYMBOL 
  / ADDDATE_SYMBOL 
  / AFTER_SYMBOL 
  / AGAINST_SYMBOL 
  / AGGREGATE_SYMBOL 
  / ALGORITHM_SYMBOL 
  / ANALYSE_SYMBOL 
  / ANY_SYMBOL 
  / AT_SYMBOL 
  / AUTHORS_SYMBOL 
  / AUTO_INCREMENT_SYMBOL 
  / AUTOEXTEND_SIZE_SYMBOL 
  / AVG_ROW_LENGTH_SYMBOL 
  / AVG_SYMBOL 
  / BINLOG_SYMBOL 
  / BIT_SYMBOL 
  / BLOCK_SYMBOL 
  / BOOL_SYMBOL 
  / BOOLEAN_SYMBOL 
  / BTREE_SYMBOL 
  / BUCKETS_SYMBOL 
  / CASCADED_SYMBOL 
  / CATALOG_NAME_SYMBOL 
  / CHAIN_SYMBOL 
  / CHANGED_SYMBOL 
  / CHANNEL_SYMBOL 
  / CIPHER_SYMBOL 
  / CLIENT_SYMBOL 
  / CLASS_ORIGIN_SYMBOL 
  / COALESCE_SYMBOL 
  / CODE_SYMBOL 
  / COLLATION_SYMBOL 
  / COLUMN_NAME_SYMBOL 
  / COLUMN_FORMAT_SYMBOL 
  / COLUMNS_SYMBOL 
  / COMMITTED_SYMBOL 
  / COMPACT_SYMBOL 
  / COMPLETION_SYMBOL 
  / COMPONENT_SYMBOL 
  / COMPRESSED_SYMBOL 
  / COMPRESSION_SYMBOL 
  / CONCURRENT_SYMBOL 
  / CONNECTION_SYMBOL 
  / CONSISTENT_SYMBOL 
  / CONSTRAINT_CATALOG_SYMBOL 
  / CONSTRAINT_SCHEMA_SYMBOL 
  / CONSTRAINT_NAME_SYMBOL 
  / CONTEXT_SYMBOL 
  / CONTRIBUTORS_SYMBOL 
  / CPU_SYMBOL 
  / CURRENT_SYMBOL 
  / CURSOR_NAME_SYMBOL 
  / DATA_SYMBOL 
  / DATAFILE_SYMBOL 
  / DATETIME_SYMBOL 
  / DATE_SYMBOL 
  / DAY_SYMBOL 
  / DEFAULT_AUTH_SYMBOL 
  / DEFINER_SYMBOL 
  / DELAY_KEY_WRITE_SYMBOL 
  / DES_KEY_FILE_SYMBOL 
  / DESCRIPTION_SYMBOL 
  / DIAGNOSTICS_SYMBOL 
  / DIRECTORY_SYMBOL 
  / DISABLE_SYMBOL 
  / DISCARD_SYMBOL 
  / DISK_SYMBOL 
  / DUMPFILE_SYMBOL 
  / DUPLICATE_SYMBOL 
  / DYNAMIC_SYMBOL 
  / ENCRYPTION_SYMBOL 
  / ENDS_SYMBOL 
  / ENUM_SYMBOL 
  / ENGINE_SYMBOL 
  / ENGINES_SYMBOL 
  / ERROR_SYMBOL 
  / ERRORS_SYMBOL 
  / ESCAPE_SYMBOL 
  / EVENTS_SYMBOL 
  / EVERY_SYMBOL 
  / EXCLUDE_SYMBOL 
  / EXPANSION_SYMBOL 
  / EXPORT_SYMBOL 
  / EXTENDED_SYMBOL 
  / EXTENT_SIZE_SYMBOL 
  / FAULTS_SYMBOL 
  / FAST_SYMBOL 
  / FOLLOWING_SYMBOL 
  / FOUND_SYMBOL 
  / ENABLE_SYMBOL 
  / FULL_SYMBOL 
  / FILE_BLOCK_SIZE_SYMBOL 
  / FILTER_SYMBOL 
  / FIRST_SYMBOL 
  / FIXED_SYMBOL 
  / GENERAL_SYMBOL 
  / GEOMETRY_SYMBOL 
  / GEOMETRYCOLLECTION_SYMBOL 
  / GET_FORMAT_SYMBOL 
  / GRANTS_SYMBOL 
  / GLOBAL_SYMBOL 
  / HASH_SYMBOL 
  / HISTOGRAM_SYMBOL 
  / HISTORY_SYMBOL 
  / HOSTS_SYMBOL 
  / HOUR_SYMBOL 
  / IDENTIFIED_SYMBOL 
  / IGNORE_SERVER_IDS_SYMBOL 
  / INVOKER_SYMBOL 
  / INDEXES_SYMBOL 
  / INITIAL_SIZE_SYMBOL 
  / INSTANCE_SYMBOL 
  / INACTIVE_SYMBOL 
  / IO_SYMBOL 
  / IPC_SYMBOL 
  / ISOLATION_SYMBOL 
  / ISSUER_SYMBOL 
  / INSERT_METHOD_SYMBOL 
  / JSON_SYMBOL 
  / KEY_BLOCK_SIZE_SYMBOL 
  / LAST_SYMBOL 
  / LEAVES_SYMBOL 
  / LESS_SYMBOL 
  / LEVEL_SYMBOL 
  / LINESTRING_SYMBOL 
  / LIST_SYMBOL 
  / LOCAL_SYMBOL 
  / LOCKED_SYMBOL 
  / LOCKS_SYMBOL 
  / LOGFILE_SYMBOL 
  / LOGS_SYMBOL 
  / MAX_ROWS_SYMBOL 
  / MASTER_SYMBOL 
  / MASTER_HEARTBEAT_PERIOD_SYMBOL 
  / MASTER_HOST_SYMBOL 
  / MASTER_PORT_SYMBOL 
  / MASTER_LOG_FILE_SYMBOL 
  / MASTER_LOG_POS_SYMBOL 
  / MASTER_USER_SYMBOL 
  / MASTER_PASSWORD_SYMBOL 
  / MASTER_PUBLIC_KEY_PATH_SYMBOL 
  / MASTER_SERVER_ID_SYMBOL 
  / MASTER_CONNECT_RETRY_SYMBOL 
  / MASTER_RETRY_COUNT_SYMBOL 
  / MASTER_DELAY_SYMBOL 
  / MASTER_SSL_SYMBOL 
  / MASTER_SSL_CA_SYMBOL 
  / MASTER_SSL_CAPATH_SYMBOL 
  / MASTER_TLS_VERSION_SYMBOL 
  / MASTER_SSL_CERT_SYMBOL 
  / MASTER_SSL_CIPHER_SYMBOL 
  / MASTER_SSL_CRL_SYMBOL 
  / MASTER_SSL_CRLPATH_SYMBOL 
  / MASTER_SSL_KEY_SYMBOL 
  / MASTER_AUTO_POSITION_SYMBOL 
  / MAX_CONNECTIONS_PER_HOUR_SYMBOL 
  / MAX_QUERIES_PER_HOUR_SYMBOL 
  / MAX_STATEMENT_TIME_SYMBOL 
  / MAX_SIZE_SYMBOL 
  / MAX_UPDATES_PER_HOUR_SYMBOL 
  / MAX_USER_CONNECTIONS_SYMBOL 
  / MEDIUM_SYMBOL 
  / MEMORY_SYMBOL 
  / MERGE_SYMBOL 
  / MESSAGE_TEXT_SYMBOL 
  / MICROSECOND_SYMBOL 
  / MIGRATE_SYMBOL 
  / MINUTE_SYMBOL 
  / MIN_ROWS_SYMBOL 
  / MODIFY_SYMBOL 
  / MODE_SYMBOL 
  / MONTH_SYMBOL 
  / MULTILINESTRING_SYMBOL 
  / MULTIPOINT_SYMBOL 
  / MULTIPOLYGON_SYMBOL 
  / MUTEX_SYMBOL 
  / MYSQL_ERRNO_SYMBOL 
  / NAME_SYMBOL 
  / NAMES_SYMBOL 
  / NATIONAL_SYMBOL 
  / NCHAR_SYMBOL 
  / NDBCLUSTER_SYMBOL 
  / NESTED_SYMBOL 
  / NEVER_SYMBOL 
  / NEXT_SYMBOL 
  / NEW_SYMBOL 
  / NO_WAIT_SYMBOL 
  / NODEGROUP_SYMBOL 
  / NULLS_SYMBOL 
  / NOWAIT_SYMBOL 
  / NUMBER_SYMBOL 
  / NVARCHAR_SYMBOL 
  / OFFSET_SYMBOL 
  / OLD_SYMBOL 
  / OLD_PASSWORD_SYMBOL 
  / ONE_SYMBOL 
  / OPTIONAL_SYMBOL 
  / ORDINALITY_SYMBOL 
  / ORGANIZATION_SYMBOL 
  / OTHERS_SYMBOL 
  / PACK_KEYS_SYMBOL 
  / PAGE_SYMBOL 
  / PARTIAL_SYMBOL 
  / PARTITIONING_SYMBOL 
  / PARTITIONS_SYMBOL 
  / PASSWORD_SYMBOL 
  / PATH_SYMBOL 
  / PHASE_SYMBOL 
  / PLUGIN_DIR_SYMBOL 
  / PLUGIN_SYMBOL 
  / PLUGINS_SYMBOL 
  / POINT_SYMBOL 
  / POLYGON_SYMBOL 
  / PRECEDING_SYMBOL 
  / PRESERVE_SYMBOL 
  / PREV_SYMBOL 
  / THREAD_PRIORITY_SYMBOL 
  / PRIVILEGES_SYMBOL 
  / PROCESSLIST_SYMBOL 
  / PROFILE_SYMBOL 
  / PROFILES_SYMBOL 
  / QUARTER_SYMBOL 
  / QUERY_SYMBOL 
  / QUICK_SYMBOL 
  / READ_ONLY_SYMBOL 
  / REBUILD_SYMBOL 
  / RECOVER_SYMBOL 
  / REDO_BUFFER_SIZE_SYMBOL 
  / REDOFILE_SYMBOL 
  / REDUNDANT_SYMBOL 
  / RELAY_SYMBOL 
  / RELAYLOG_SYMBOL 
  / RELAY_LOG_FILE_SYMBOL 
  / RELAY_LOG_POS_SYMBOL 
  / RELAY_THREAD_SYMBOL 
  / REMOTE_SYMBOL 
  / REORGANIZE_SYMBOL 
  / REPEATABLE_SYMBOL 
  / REPLICATE_DO_DB_SYMBOL 
  / REPLICATE_IGNORE_DB_SYMBOL 
  / REPLICATE_DO_TABLE_SYMBOL 
  / REPLICATE_IGNORE_TABLE_SYMBOL 
  / REPLICATE_WILD_DO_TABLE_SYMBOL 
  / REPLICATE_WILD_IGNORE_TABLE_SYMBOL 
  / REPLICATE_REWRITE_DB_SYMBOL 
  / USER_RESOURCES_SYMBOL 
  / RESPECT_SYMBOL 
  / RESUME_SYMBOL 
  / RETAIN_SYMBOL 
  / RETURNED_SQLSTATE_SYMBOL 
  / RETURNS_SYMBOL 
  / REUSE_SYMBOL 
  / REVERSE_SYMBOL 
  / ROLLUP_SYMBOL 
  / ROTATE_SYMBOL 
  / ROUTINE_SYMBOL 
  / ROW_COUNT_SYMBOL 
  / ROW_FORMAT_SYMBOL 
  / RTREE_SYMBOL 
  / SCHEDULE_SYMBOL 
  / SCHEMA_NAME_SYMBOL 
  / SECOND_SYMBOL 
  / SERIAL_SYMBOL 
  / SERIALIZABLE_SYMBOL 
  / SESSION_SYMBOL 
  / SHARE_SYMBOL 
  / SIMPLE_SYMBOL 
  / SKIP_SYMBOL 
  / SLOW_SYMBOL 
  / SNAPSHOT_SYMBOL 
  / SOUNDS_SYMBOL 
  / SOURCE_SYMBOL 
  / SQL_AFTER_GTIDS_SYMBOL 
  / SQL_AFTER_MTS_GAPS_SYMBOL 
  / SQL_BEFORE_GTIDS_SYMBOL 
  / SQL_CACHE_SYMBOL 
  / SQL_BUFFER_RESULT_SYMBOL 
  / SQL_NO_CACHE_SYMBOL 
  / SQL_THREAD_SYMBOL 
  / SRID_SYMBOL 
  / STACKED_SYMBOL 
  / STARTS_SYMBOL 
  / STATS_AUTO_RECALC_SYMBOL 
  / STATS_PERSISTENT_SYMBOL 
  / STATS_SAMPLE_PAGES_SYMBOL 
  / STATUS_SYMBOL 
  / STORAGE_SYMBOL 
  / STRING_SYMBOL 
  / SUBCLASS_ORIGIN_SYMBOL 
  / SUBDATE_SYMBOL 
  / SUBJECT_SYMBOL 
  / SUBPARTITION_SYMBOL 
  / SUBPARTITIONS_SYMBOL 
  / SUPER_SYMBOL 
  / SUSPEND_SYMBOL 
  / SWAPS_SYMBOL 
  / SWITCHES_SYMBOL 
  / TABLE_NAME_SYMBOL 
  / TABLES_SYMBOL 
  / TABLE_CHECKSUM_SYMBOL 
  / TABLESPACE_SYMBOL 
  / TEMPORARY_SYMBOL 
  / TEMPTABLE_SYMBOL 
  / TEXT_SYMBOL 
  / THAN_SYMBOL 
  / TIES_SYMBOL 
  / TRANSACTION_SYMBOL 
  / TRIGGERS_SYMBOL 
  / TIMESTAMP_SYMBOL 
  / TIMESTAMP_ADD_SYMBOL 
  / TIMESTAMP_DIFF_SYMBOL 
  / TIME_SYMBOL 
  / TYPES_SYMBOL 
  / TYPE_SYMBOL 
  / UDF_RETURNS_SYMBOL 
  / UNBOUNDED_SYMBOL 
  / UNCOMMITTED_SYMBOL 
  / UNDEFINED_SYMBOL 
  / UNDO_BUFFER_SIZE_SYMBOL 
  / UNDOFILE_SYMBOL 
  / UNKNOWN_SYMBOL 
  / UNTIL_SYMBOL 
  / USER_SYMBOL 
  / USE_FRM_SYMBOL 
  / VARIABLES_SYMBOL 
  / VCPU_SYMBOL 
  / VIEW_SYMBOL 
  / VALUE_SYMBOL 
  / WARNINGS_SYMBOL 
  / WAIT_SYMBOL 
  / WEEK_SYMBOL 
  / WORK_SYMBOL 
  / WEIGHT_STRING_SYMBOL 
  / X509_SYMBOL 
  / XID_SYMBOL 
  / XML_SYMBOL 
  / YEAR_SYMBOL) 
  / SHUTDOWN_SYMBOL 
  / (CUBE_SYMBOL 
  / IMPORT_SYMBOL 
  / FUNCTION_SYMBOL 
  / ROWS_SYMBOL 
  / ROW_SYMBOL) 
  / (EXCHANGE_SYMBOL 
  / EXPIRE_SYMBOL 
  / ONLY_SYMBOL 
  / SUPER_SYMBOL 
  / VALIDATION_SYMBOL 
  / WITHOUT_SYMBOL) 
  / ADMIN_SYMBOL


{
  const identifier = require('./identifier');
}


EQUAL_OPERATOR
  = '='

ASSIGN_OPERATOR
  = ':='

NULL_SAFE_EQUAL_OPERATOR
  = '<=>'

GREATER_OR_EQUAL_OPERATOR
  = '>='

GREATER_THAN_OPERATOR
  = '>'

LESS_OR_EQUAL_OPERATOR
  = '<='

LESS_THAN_OPERATOR
  = '<'

NOT_EQUAL_OPERATOR
  = '!='

NOT_EQUAL2_OPERATOR
  = '<>' { return 'NOT_EQUAL_OPERATOR'; }

PLUS_OPERATOR
  = '+'

MINUS_OPERATOR
  = '-'

MULT_OPERATOR
  = '*'

DIV_OPERATOR
  = '/'

MOD_OPERATOR
  = '%'

LOGICAL_NOT_OPERATOR
  = '!'

BITWISE_NOT_OPERATOR
  = '~'

SHIFT_LEFT_OPERATOR
  = '<<'

SHIFT_RIGHT_OPERATOR
  = '>>'

LOGICAL_AND_OPERATOR
  = '&&'

BITWISE_AND_OPERATOR
  = '&'

BITWISE_XOR_OPERATOR
  = '^'

LOGICAL_OR_OPERATOR
  = '||' { return options.isSqlModeActive('PipesAsConcat') ? 'CONCAT_PIPES_SYMBOL' : 'LOGICAL_OR_OPERATOR'; }

BITWISE_OR_OPERATOR
  = '|'

DOT_SYMBOL
  = '.'

COMMA_SYMBOL
  = ','

SEMICOLON_SYMBOL
  = ';'

COLON_SYMBOL
  = ':'

OPEN_PAR_SYMBOL
  = '('

CLOSE_PAR_SYMBOL
  = ')'

OPEN_CURLY_SYMBOL
  = '{'

CLOSE_CURLY_SYMBOL
  = '}'

UNDERLINE_SYMBOL
  = '_'

JSON_SEPARATOR_SYMBOL
  = '->' { return options.serverVersion >= 50708 ? 'JSON_SEPARATOR_SYMBOL' : null; } // MYSQL

JSON_UNQUOTED_SEPARATOR_SYMBOL
  = '->>' { return options.serverVersion >= 50713 ? 'JSON_UNQUOTED_SEPARATOR_SYMBOL' : null; } // MYSQL

AT_SIGN_SYMBOL
  = '@'

AT_TEXT_SUFFIX
  = '@' SIMPLE_IDENTIFIER

AT_AT_SIGN_SYMBOL
  = '@@'

NULL2_SYMBOL
  = '\\N'

PARAM_MARKER
  = '?'

A
  = 'a' / 'A'

B
  = 'b' / 'B'

C
  = 'c' / 'C'

D
  = 'd' / 'D'

E
  = 'e' / 'E'

F
  = 'f' / 'F'

G
  = 'g' / 'G'

H
  = 'h' / 'H'

I
  = 'i' / 'I'

J
  = 'j' / 'J'

K
  = 'k' / 'K'

L
  = 'l' / 'L'

M
  = 'm' / 'M'

N
  = 'n' / 'N'

O
  = 'o' / 'O'

P
  = 'p' / 'P'

Q
  = 'q' / 'Q'

R
  = 'r' / 'R'

S
  = 's' / 'S'

T
   = 't' / 'T'

U
  = 'u' / 'U'

V
  = 'v' / 'V'

W
  = 'w' / 'W'

X
  = 'x' / 'X'

Y
  = 'y' / 'Y'

Z
  = 'z' / 'Z'

DIGIT
  = [0-9]

DIGITS
  = DIGIT+

HEXDIGIT
  = [0-9a-fA-F]

HEX_NUMBER
  = '0x' HEXDIGIT+
  / "x'" HEXDIGIT+ "'"

BIN_NUMBER
  = '0b' [01]+
  / "b'" [01]+ "'"

INT_NUMBER
  = DIGITS { return identifier.determineNumericType(text()); }

LONG_NUMBER
  = INT_NUMBER

ULONGLONG_NUMBER
  = INT_NUMBER

DECIMAL_NUMBER
  = DIGITS? '.' DIGITS

FLOAT_NUMBER
  = (DIGITS? '.')? DIGITS [eE] (MINUS_OPERATOR / PLUS_OPERATOR)? DIGITS

DOT_IDENTIFIER
  = '.' LETTER_WHEN_UNQUOTED_NO_DIGIT LETTER_WHEN_UNQUOTED* {
      options.emitDot();
      return 'IDENTIFIER';
    }

UNDERSCORE_CHARSET
  = '_' [a-z0-9]+ { return options.checkCharset(text()); }

IDENTIFIER
  = DIGITS+ [eE] (LETTER_WHEN_UNQUOTED_NO_DIGIT LETTER_WHEN_UNQUOTED*)?
  / DIGITS+ LETTER_WITHOUT_FLOAT_PART LETTER_WHEN_UNQUOTED*
  / LETTER_WHEN_UNQUOTED_NO_DIGIT LETTER_WHEN_UNQUOTED*

NCHAR_TEXT
  = [nN] SINGLE_QUOTED_TEXT

BACK_TICK
  = '`'

SINGLE_QUOTE
  = "'"

DOUBLE_QUOTE
  = '"'

BACK_TICK_QUOTED_ID
    = BACK_TICK (BACK_TICK_ESCAPE / BACK_TICK_CONTENT)* BACK_TICK

BACK_TICK_ESCAPE
    = '\\' .

BACK_TICK_CONTENT
    = !BACK_TICK .


DOUBLE_QUOTED_TEXT
  = (DOUBLE_QUOTE DOUBLE_QUOTED_CONTENT DOUBLE_QUOTE)+

DOUBLE_QUOTED_CONTENT
  = (DOUBLE_QUOTE_ESCAPE / DOUBLE_QUOTE_CHAR)*

DOUBLE_QUOTE_ESCAPE
  = '\\' .

DOUBLE_QUOTE_CHAR
  = !DOUBLE_QUOTE .

SINGLE_QUOTED_TEXT
  = (SINGLE_QUOTE SINGLE_QUOTED_CONTENT SINGLE_QUOTE)+

SINGLE_QUOTED_CONTENT
  = (SINGLE_QUOTE_ESCAPE / SINGLE_QUOTE_CHAR)*

SINGLE_QUOTE_ESCAPE
  = '\\' .

SINGLE_QUOTE_CHAR
  = !SINGLE_QUOTE .


VERSION_COMMENT_START
  = '/*!' DIGITS (
      &{ return options.checkVersion(text()); }
      / VERSION_COMMENT_CONTENT '*/'
    ) { return ''; }

VERSION_COMMENT_CONTENT
  = (!'*/' .)*


MYSQL_COMMENT_START
  = '/*!' { options.inVersionComment = true; return ''; }

VERSION_COMMENT_END
  = '*/' &{ return options.inVersionComment; } { options.inVersionComment = false; return ''; }

BLOCK_COMMENT
  = ('/**/' / '/*' BLOCK_COMMENT_CONTENT '*/') { return ''; }

BLOCK_COMMENT_CONTENT
  = (!'*/' .)*

POUND_COMMENT
  = '#' [^\n\r]* { return ''; }

DASHDASH_COMMENT
  = DOUBLE_DASH ([ \t] [^\n\r]* / LINEBREAK / "") { return ''; }

DOUBLE_DASH
  = '--'

LINEBREAK
  = [\n\r]

SIMPLE_IDENTIFIER
  = (DIGIT / [a-zA-Z_$] / '.')+

ML_COMMENT_HEAD
  = '/*'

ML_COMMENT_END
  = '*/'

LETTER_WHEN_UNQUOTED
  = DIGIT / LETTER_WHEN_UNQUOTED_NO_DIGIT

LETTER_WHEN_UNQUOTED_NO_DIGIT
  = [a-zA-Z_$\u0080-\uffff]

LETTER_WITHOUT_FLOAT_PART
  = [a-df-zA-DF-Z_$\u0080-\uffff]

ACCESSIBLE_SYMBOL
  = 'ACCESSIBLE'

ACCOUNT_SYMBOL
  = 'ACCOUNT' &{ return options.serverVersion >= 50707; }

ACTION_SYMBOL
  = 'ACTION'

ADD_SYMBOL
  = 'ADD'

ADDDATE_SYMBOL
  = 'ADDDATE' { return identifier.determineFunction('ADDDATE_SYMBOL'); } // MYSQL-FUNC

AFTER_SYMBOL
  = 'AFTER'

AGAINST_SYMBOL
  = 'AGAINST'

AGGREGATE_SYMBOL
  = 'AGGREGATE'

ALGORITHM_SYMBOL
  = 'ALGORITHM'

ALL_SYMBOL
  = 'ALL'

ALTER_SYMBOL
  = 'ALTER'

ALWAYS_SYMBOL
  = 'ALWAYS' &{ return options.serverVersion >= 50707; }

ANALYSE_SYMBOL
  = 'ANALYSE' &{ return options.serverVersion < 80000; }

ANALYZE_SYMBOL
  = 'ANALYZE'

AND_SYMBOL
  = 'AND'

ANY_SYMBOL
  = 'ANY'

AS_SYMBOL
  = 'AS'

ASC_SYMBOL
  = 'ASC'

ASCII_SYMBOL
  = 'ASCII' { return identifier.determineFunction('ASCII_SYMBOL'); } // MYSQL-FUNC

ASENSITIVE_SYMBOL
  = 'ASENSITIVE' // FUTURE-USE

AT_SYMBOL
  = 'AT'

AUTHORS_SYMBOL
   = 'AUTHORS' &{ return options.serverVersion < 50700; }

AUTOEXTEND_SIZE_SYMBOL
  = 'AUTOEXTEND_SIZE'

AUTO_INCREMENT_SYMBOL
  = 'AUTO_INCREMENT'

AVG_ROW_LENGTH_SYMBOL
  = 'AVG_ROW_LENGTH'

AVG_SYMBOL
  = 'AVG' { return identifier.determineFunction('AVG_SYMBOL'); } // SQL-2003-N

BACKUP_SYMBOL
  = 'BACKUP'

BEFORE_SYMBOL
  = 'BEFORE'

BEGIN_SYMBOL
  = 'BEGIN'

BETWEEN_SYMBOL
  = 'BETWEEN'

BIGINT_SYMBOL
  = 'BIGINT'

BINARY_SYMBOL
  = 'BINARY'

BINLOG_SYMBOL
  = 'BINLOG'

BIN_NUM_SYMBOL
  = 'BIN_NUM'

BIT_AND_SYMBOL
  = 'BIT_AND' { return identifier.determineFunction('BIT_AND_SYMBOL'); } // MYSQL-FUNC

BIT_OR_SYMBOL
  = 'BIT_OR' { return identifier.determineFunction('BIT_OR_SYMBOL'); } // MYSQL-FUNC

BIT_SYMBOL
  = 'BIT' // MYSQL-FUNC

BIT_XOR_SYMBOL
  = 'BIT_XOR' { return identifier.determineFunction('BIT_XOR_SYMBOL'); } // MYSQL-FUNC

BLOB_SYMBOL
  = 'BLOB'

BLOCK_SYMBOL
  = 'BLOCK'

BOOLEAN_SYMBOL
  = 'BOOLEAN'

BOOL_SYMBOL
  = 'BOOL'

BOTH_SYMBOL
  = 'BOTH'

BTREE_SYMBOL
  = 'BTREE'

BY_SYMBOL
  = 'BY'

BYTE_SYMBOL
  = 'BYTE'

CACHE_SYMBOL
  = 'CACHE'

CALL_SYMBOL
  = 'CALL'

CASCADE_SYMBOL
  = 'CASCADE'

CASCADED_SYMBOL
  = 'CASCADED'

CASE_SYMBOL
  = 'CASE'

CAST_SYMBOL
  = 'CAST' { return identifier.determineFunction('CAST_SYMBOL'); } // SQL-2003-R

CATALOG_NAME_SYMBOL
  = 'CATALOG_NAME'

CHAIN_SYMBOL
  = 'CHAIN'

CHANGE_SYMBOL
  = 'CHANGE'

CHANGED_SYMBOL
  = 'CHANGED'

CHANNEL_SYMBOL
  = 'CHANNEL' &{ return options.serverVersion >= 50706; }

CHARSET_SYMBOL
  = 'CHARSET'

CHARACTER_SYMBOL
  = 'CHARACTER' { return 'CHAR_SYMBOL'; } // Synonym

CHAR_SYMBOL
  = 'CHAR'

CHECKSUM_SYMBOL
  = 'CHECKSUM'

CHECK_SYMBOL
  = 'CHECK'

CIPHER_SYMBOL
  = 'CIPHER'

CLASS_ORIGIN_SYMBOL
  = 'CLASS_ORIGIN'

CLIENT_SYMBOL
  = 'CLIENT'

CLOSE_SYMBOL
  = 'CLOSE'

COALESCE_SYMBOL
  = 'COALESCE'

CODE_SYMBOL
  = 'CODE'

COLLATE_SYMBOL
  = 'COLLATE'

COLLATION_SYMBOL
  = 'COLLATION'

COLUMNS_SYMBOL
  = 'COLUMNS'

COLUMN_SYMBOL
  = 'COLUMN'

COLUMN_NAME_SYMBOL
  = 'COLUMN_NAME'

COLUMN_FORMAT_SYMBOL
  = 'COLUMN_FORMAT'

COMMENT_SYMBOL
  = 'COMMENT'

COMMITTED_SYMBOL
  = 'COMMITTED'

COMMIT_SYMBOL
  = 'COMMIT'

COMPACT_SYMBOL
  = 'COMPACT'

COMPLETION_SYMBOL
  = 'COMPLETION'

COMPRESSED_SYMBOL
  = 'COMPRESSED'

COMPRESSION_SYMBOL
  = 'COMPRESSION' &{ return options.serverVersion >= 50707; }

CONCURRENT_SYMBOL
  = 'CONCURRENT'

CONDITION_SYMBOL
  = 'CONDITION'

CONNECTION_SYMBOL
  = 'CONNECTION'

CONSISTENT_SYMBOL
  = 'CONSISTENT'

CONSTRAINT_SYMBOL
  = 'CONSTRAINT'

CONSTRAINT_CATALOG_SYMBOL
  = 'CONSTRAINT_CATALOG'

CONSTRAINT_NAME_SYMBOL
  = 'CONSTRAINT_NAME'

CONSTRAINT_SCHEMA_SYMBOL
  = 'CONSTRAINT_SCHEMA'

CONTAINS_SYMBOL
  = 'CONTAINS'

CONTEXT_SYMBOL
  = 'CONTEXT'

CONTINUE_SYMBOL
  = 'CONTINUE'

CONTRIBUTORS_SYMBOL
  = 'CONTRIBUTORS' &{ return options.serverVersion < 50700; }

CONVERT_SYMBOL
  = 'CONVERT'

COUNT_SYMBOL
  = 'COUNT' { return identifier.determineFunction('COUNT_SYMBOL'); } // SQL-2003-N

CPU_SYMBOL
  = 'CPU'

CREATE_SYMBOL
  = 'CREATE'

CROSS_SYMBOL
  = 'CROSS'

CUBE_SYMBOL
  = 'CUBE'

CURDATE_SYMBOL
  = 'CURDATE' { return identifier.determineFunction('CURDATE_SYMBOL'); } // MYSQL-FUNC

CURRENT_SYMBOL
  = 'CURRENT' &{ return options.serverVersion >= 50604; }

CURRENT_DATE_SYMBOL
  = 'CURRENT_DATE' { return identifier.determineFunction('CURDATE_SYMBOL'); } // Synonym, MYSQL-FUNC

CURRENT_TIME_SYMBOL
  = 'CURRENT_TIME' { return identifier.determineFunction('CURTIME_SYMBOL'); } // Synonym, MYSQL-FUNC

CURRENT_TIMESTAMP_SYMBOL
  = 'CURRENT_TIMESTAMP' { return 'NOW_SYMBOL'; } // Synonym

CURRENT_USER_SYMBOL
  = 'CURRENT_USER'

CURSOR_SYMBOL
  = 'CURSOR'

CURSOR_NAME_SYMBOL
  = 'CURSOR_NAME'

CURTIME_SYMBOL
  = 'CURTIME' { return identifier.determineFunction('CURTIME_SYMBOL'); } // MYSQL-FUNC

DATABASE_SYMBOL
  = 'DATABASE'

DATABASES_SYMBOL
  = 'DATABASES'

DATAFILE_SYMBOL
  = 'DATAFILE'

DATA_SYMBOL
  = 'DATA'

DATETIME_SYMBOL
  = 'DATETIME' // MYSQL

DATE_ADD_SYMBOL
  = 'DATE_ADD' { return identifier.determineFunction('DATE_ADD_SYMBOL'); }

DATE_SUB_SYMBOL
  = 'DATE_SUB' { return identifier.determineFunction('DATE_SUB_SYMBOL'); }

DATE_SYMBOL
  = 'DATE'

DAYOFMONTH_SYMBOL
  = 'DAYOFMONTH' { return 'DAY_SYMBOL'; } // Synonym

DAY_HOUR_SYMBOL
  = 'DAY_HOUR'

DAY_MICROSECOND_SYMBOL
  = 'DAY_MICROSECOND'

DAY_MINUTE_SYMBOL
  = 'DAY_MINUTE'

DAY_SECOND_SYMBOL
  = 'DAY_SECOND'

DAY_SYMBOL
  = 'DAY'

DEALLOCATE_SYMBOL
  = 'DEALLOCATE'

DEC_SYMBOL
  = 'DEC' { return 'DECIMAL_SYMBOL'; } // Synonym

DECIMAL_NUM_SYMBOL
  = 'DECIMAL_NUM'

DECIMAL_SYMBOL
  = 'DECIMAL'

DECLARE_SYMBOL
  = 'DECLARE'

DEFAULT_SYMBOL
  = 'DEFAULT'

DEFAULT_AUTH_SYMBOL
  = 'DEFAULT_AUTH' &{ return options.serverVersion >= 50604; } // Internal

DEFINER_SYMBOL
  = 'DEFINER'

DELAYED_SYMBOL
  = 'DELAYED'

DELAY_KEY_WRITE_SYMBOL
  = 'DELAY_KEY_WRITE'

DELETE_SYMBOL
  = 'DELETE'

DESC_SYMBOL
  = 'DESC'

DESCRIBE_SYMBOL
  = 'DESCRIBE'

DES_KEY_FILE_SYMBOL
  = 'DES_KEY_FILE' &{ return options.serverVersion < 80000; }

DETERMINISTIC_SYMBOL
  = 'DETERMINISTIC'

DIAGNOSTICS_SYMBOL
  = 'DIAGNOSTICS'

DIRECTORY_SYMBOL
  = 'DIRECTORY'

DISABLE_SYMBOL
  = 'DISABLE'

DISCARD_SYMBOL
  = 'DISCARD'

DISK_SYMBOL
  = 'DISK'

DISTINCT_SYMBOL
  = 'DISTINCT'

DISTINCTROW_SYMBOL
  = 'DISTINCTROW' { return 'DISTINCT_SYMBOL'; } // Synonym

DIV_SYMBOL
  = 'DIV'

DOUBLE_SYMBOL
  = 'DOUBLE'

DO_SYMBOL
  = 'DO'

DROP_SYMBOL
  = 'DROP'

DUAL_SYMBOL
  = 'DUAL'

DUMPFILE_SYMBOL
  = 'DUMPFILE'

DUPLICATE_SYMBOL
  = 'DUPLICATE'

DYNAMIC_SYMBOL
  = 'DYNAMIC'

EACH_SYMBOL
  = 'EACH'

ELSE_SYMBOL
  = 'ELSE'

ELSEIF_SYMBOL
  = 'ELSEIF'

ENABLE_SYMBOL
  = 'ENABLE'

ENCLOSED_SYMBOL
  = 'ENCLOSED'

ENCRYPTION_SYMBOL
  = 'ENCRYPTION' &{ return options.serverVersion >= 50711; }

END_SYMBOL
  = 'END'

ENDS_SYMBOL
  = 'ENDS'

END_OF_INPUT_SYMBOL
  = 'END_OF_INPUT' // INTERNAL

ENGINES_SYMBOL
  = 'ENGINES'

ENGINE_SYMBOL
  = 'ENGINE'

ENUM_SYMBOL
  = 'ENUM' // MYSQL

ERROR_SYMBOL
  = 'ERROR'

ERRORS_SYMBOL
  = 'ERRORS'

ESCAPED_SYMBOL
  = 'ESCAPED'

ESCAPE_SYMBOL
  = 'ESCAPE'

EVENTS_SYMBOL
  = 'EVENTS'

EVENT_SYMBOL
  = 'EVENT'

EVERY_SYMBOL
  = 'EVERY'

EXCHANGE_SYMBOL
  = 'EXCHANGE'

EXECUTE_SYMBOL
  = 'EXECUTE'

EXISTS_SYMBOL
  = 'EXISTS'

EXIT_SYMBOL
  = 'EXIT'

EXPANSION_SYMBOL
  = 'EXPANSION'

EXPIRE_SYMBOL
  = 'EXPIRE' &{ return options.serverVersion >= 50606; }

EXPLAIN_SYMBOL
  = 'EXPLAIN'

EXPORT_SYMBOL
  = 'EXPORT' &{ return options.serverVersion >= 50606; }

EXTENDED_SYMBOL
  = 'EXTENDED'

EXTENT_SIZE_SYMBOL
  = 'EXTENT_SIZE'

EXTRACT_SYMBOL
  = 'EXTRACT' { return identifier.determineFunction('EXTRACT_SYMBOL'); } // SQL-2003-N

FALSE_SYMBOL
  = 'FALSE'

FAST_SYMBOL
  = 'FAST'

FAULTS_SYMBOL
  = 'FAULTS'

FETCH_SYMBOL
  = 'FETCH'

FIELDS_SYMBOL
  = 'FIELDS' { return 'COLUMNS_SYMBOL'; } // Synonym

FILE_SYMBOL
  = 'FILE'

FILE_BLOCK_SIZE_SYMBOL
  = 'FILE_BLOCK_SIZE' &{ return options.serverVersion >= 50707; }

FILTER_SYMBOL
  = 'FILTER' &{ return options.serverVersion >= 50700; }

FIRST_SYMBOL
  = 'FIRST'

FIXED_SYMBOL
  = 'FIXED'

FLOAT4_SYMBOL
  = 'FLOAT4' { return 'FLOAT_SYMBOL'; } // Synonym

FLOAT8_SYMBOL
  = 'FLOAT8' { return 'DOUBLE_SYMBOL'; } // Synonym

FLOAT_SYMBOL
  = 'FLOAT'

FLUSH_SYMBOL
  = 'FLUSH'

FOLLOWS_SYMBOL
  = 'FOLLOWS' &{ return options.serverVersion >= 50700; }

FORCE_SYMBOL
  = 'FORCE'

FOREIGN_SYMBOL
  = 'FOREIGN'

FOR_SYMBOL
  = 'FOR'

FORMAT_SYMBOL
  = 'FORMAT'

FOUND_SYMBOL
  = 'FOUND'

FROM_SYMBOL
  = 'FROM'

FULL_SYMBOL
  = 'FULL'

FULLTEXT_SYMBOL
  = 'FULLTEXT'

FUNCTION_SYMBOL
  = 'FUNCTION'

GET_SYMBOL
  = 'GET' &{ return options.serverVersion >= 50604; }

GENERAL_SYMBOL
  = 'GENERAL'

GENERATED_SYMBOL
  = 'GENERATED' &{ return options.serverVersion >= 50707; }

GROUP_REPLICATION_SYMBOL
  = 'GROUP_REPLICATION' &{ return options.serverVersion >= 50707; }

GEOMETRYCOLLECTION_SYMBOL
  = 'GEOMETRYCOLLECTION' // MYSQL

GEOMETRY_SYMBOL
  = 'GEOMETRY'

GET_FORMAT_SYMBOL
  = 'GET_FORMAT' // MYSQL-FUNC

GLOBAL_SYMBOL
  = 'GLOBAL'

GRANT_SYMBOL
  = 'GRANT'

GRANTS_SYMBOL
  = 'GRANTS'

GROUP_SYMBOL
  = 'GROUP'

GROUP_CONCAT_SYMBOL
  = 'GROUP_CONCAT' { return identifier.determineFunction('GROUP_CONCAT_SYMBOL'); }

HANDLER_SYMBOL
  = 'HANDLER'

HASH_SYMBOL
  = 'HASH'

HAVING_SYMBOL
  = 'HAVING'

HELP_SYMBOL
  = 'HELP'

HIGH_PRIORITY_SYMBOL
  = 'HIGH_PRIORITY'

HOST_SYMBOL
  = 'HOST'

HOSTS_SYMBOL
  = 'HOSTS'

HOUR_MICROSECOND_SYMBOL
  = 'HOUR_MICROSECOND'

HOUR_MINUTE_SYMBOL
  = 'HOUR_MINUTE'

HOUR_SECOND_SYMBOL
  = 'HOUR_SECOND'

HOUR_SYMBOL
  = 'HOUR'

IDENTIFIED_SYMBOL
  = 'IDENTIFIED'

IF_SYMBOL
  = 'IF'

IGNORE_SYMBOL
  = 'IGNORE'

IGNORE_SERVER_IDS_SYMBOL
  = 'IGNORE_SERVER_IDS'

IMPORT_SYMBOL
  = 'IMPORT'

INDEXES_SYMBOL
  = 'INDEXES'

INDEX_SYMBOL
  = 'INDEX'

INFILE_SYMBOL
  = 'INFILE'

INITIAL_SIZE_SYMBOL
  = 'INITIAL_SIZE'

INNER_SYMBOL
  = 'INNER'

INOUT_SYMBOL
  = 'INOUT'

INSENSITIVE_SYMBOL
  = 'INSENSITIVE'

INSERT_SYMBOL
  = 'INSERT'

INSERT_METHOD_SYMBOL
  = 'INSERT_METHOD'

INSTANCE_SYMBOL
  = 'INSTANCE' &{ return options.serverVersion >= 50713; }

INSTALL_SYMBOL
  = 'INSTALL'

INTEGER_SYMBOL
  = 'INTEGER' { return 'INT_SYMBOL'; } // Synonym

INTERVAL_SYMBOL
  = 'INTERVAL'

INTO_SYMBOL
  = 'INTO'

INT_SYMBOL
  = 'INT'

INVOKER_SYMBOL
  = 'INVOKER'

IN_SYMBOL
  = 'IN'

IO_AFTER_GTIDS_SYMBOL
  = 'IO_AFTER_GTIDS' // MYSQL, FUTURE-USE

IO_BEFORE_GTIDS_SYMBOL
  = 'IO_BEFORE_GTIDS' // MYSQL, FUTURE-USE

IO_THREAD_SYMBOL
  = 'IO_THREAD' { return 'RELAY_THREAD_SYMBOL'; } // Synonym

IO_SYMBOL
  = 'IO'

IPC_SYMBOL
  = 'IPC'

IS_SYMBOL
  = 'IS'

ISOLATION_SYMBOL
  = 'ISOLATION'

ISSUER_SYMBOL
  = 'ISSUER'

ITERATE_SYMBOL
  = 'ITERATE'

JOIN_SYMBOL
  = 'JOIN'

JSON_SYMBOL
  = 'JSON' &{ return options.serverVersion >= 50708; } // MYSQL

KEYS_SYMBOL
  = 'KEYS'

KEY_BLOCK_SIZE_SYMBOL
  = 'KEY_BLOCK_SIZE'

KEY_SYMBOL
  = 'KEY'

KILL_SYMBOL
  = 'KILL'

LANGUAGE_SYMBOL
  = 'LANGUAGE'

LAST_SYMBOL
  = 'LAST'

LEADING_SYMBOL
  = 'LEADING'

LEAVES_SYMBOL
  = 'LEAVES'

LEAVE_SYMBOL
  = 'LEAVE'

LEFT_SYMBOL
  = 'LEFT'

LESS_SYMBOL
  = 'LESS'

LEVEL_SYMBOL
  = 'LEVEL'

LIKE_SYMBOL
  = 'LIKE'

LIMIT_SYMBOL
  = 'LIMIT'

LINEAR_SYMBOL
  = 'LINEAR'

LINES_SYMBOL
  = 'LINES'

LINESTRING_SYMBOL
  = 'LINESTRING' // MYSQL

LIST_SYMBOL
  = 'LIST'

LOAD_SYMBOL
  = 'LOAD'

LOCALTIME_SYMBOL
  = 'LOCALTIME' { return 'NOW_SYMBOL'; } // Synonym

LOCALTIMESTAMP_SYMBOL
  = 'LOCALTIMESTAMP' { return 'NOW_SYMBOL'; } // Synonym

LOCAL_SYMBOL
  = 'LOCAL'

LOCATOR_SYMBOL
  = 'LOCATOR'

LOCKS_SYMBOL
  = 'LOCKS'

LOCK_SYMBOL
  = 'LOCK'

LOGFILE_SYMBOL
  = 'LOGFILE'

LOGS_SYMBOL
  = 'LOGS'

LONGBLOB_SYMBOL
  = 'LONGBLOB' // MYSQL

LONGTEXT_SYMBOL
  = 'LONGTEXT' // MYSQL

LONG_NUM_SYMBOL
  = 'LONG_NUM'

LONG_SYMBOL
  = 'LONG'

LOOP_SYMBOL
  = 'LOOP'

LOW_PRIORITY_SYMBOL
  = 'LOW_PRIORITY'

MASTER_AUTO_POSITION_SYMBOL
  = 'MASTER_AUTO_POSITION' &{ return options.serverVersion >= 50605; }

MASTER_BIND_SYMBOL
  = 'MASTER_BIND' &{ return options.serverVersion >= 50602; }

MASTER_CONNECT_RETRY_SYMBOL
  = 'MASTER_CONNECT_RETRY'

MASTER_DELAY_SYMBOL
  = 'MASTER_DELAY'

MASTER_HOST_SYMBOL
  = 'MASTER_HOST'

MASTER_LOG_FILE_SYMBOL
  = 'MASTER_LOG_FILE'

MASTER_LOG_POS_SYMBOL
  = 'MASTER_LOG_POS'

MASTER_PASSWORD_SYMBOL
  = 'MASTER_PASSWORD'

MASTER_PORT_SYMBOL
  = 'MASTER_PORT'

MASTER_RETRY_COUNT_SYMBOL
  = 'MASTER_RETRY_COUNT' &{ return options.serverVersion >= 50601; }

MASTER_SERVER_ID_SYMBOL
  = 'MASTER_SERVER_ID'

MASTER_SSL_CAPATH_SYMBOL
  = 'MASTER_SSL_CAPATH'

MASTER_SSL_CA_SYMBOL
  = 'MASTER_SSL_CA'

MASTER_SSL_CERT_SYMBOL
  = 'MASTER_SSL_CERT'

MASTER_SSL_CIPHER_SYMBOL
  = 'MASTER_SSL_CIPHER'

MASTER_SSL_CRL_SYMBOL
  = 'MASTER_SSL_CRL' &{ return options.serverVersion >= 50603; }

MASTER_SSL_CRLPATH_SYMBOL
  = 'MASTER_SSL_CRLPATH' &{ return options.serverVersion >= 50603; }

MASTER_SSL_KEY_SYMBOL
  = 'MASTER_SSL_KEY'

MASTER_SSL_SYMBOL
  = 'MASTER_SSL'

MASTER_SSL_VERIFY_SERVER_CERT_SYMBOL
  = 'MASTER_SSL_VERIFY_SERVER_CERT'?

MASTER_SYMBOL
  = 'MASTER'

MASTER_TLS_VERSION_SYMBOL
  = 'MASTER_TLS_VERSION' &{ return options.serverVersion >= 50713; }

MASTER_USER_SYMBOL
  = 'MASTER_USER'

MASTER_HEARTBEAT_PERIOD_SYMBOL
  = 'MASTER_HEARTBEAT_PERIOD'?

MATCH_SYMBOL
  = 'MATCH'

MAX_CONNECTIONS_PER_HOUR_SYMBOL
  = 'MAX_CONNECTIONS_PER_HOUR'

MAX_QUERIES_PER_HOUR_SYMBOL
  = 'MAX_QUERIES_PER_HOUR'

MAX_ROWS_SYMBOL
  = 'MAX_ROWS'

MAX_SIZE_SYMBOL
  = 'MAX_SIZE'

MAX_STATEMENT_TIME_SYMBOL
  = 'MAX_STATEMENT_TIME' &{ return 50704 < options.serverVersion && options.serverVersion < 50708; }

MAX_SYMBOL
  = 'MAX' { return identifier.determineFunction('MAX_SYMBOL'); } // SQL-2003-N

MAX_UPDATES_PER_HOUR_SYMBOL
  = 'MAX_UPDATES_PER_HOUR'

MAX_USER_CONNECTIONS_SYMBOL
  = 'MAX_USER_CONNECTIONS'

MAXVALUE_SYMBOL
  = 'MAXVALUE'

MEDIUMBLOB_SYMBOL
  = 'MEDIUMBLOB' // MYSQL

MEDIUMINT_SYMBOL
  = 'MEDIUMINT'

MEDIUMTEXT_SYMBOL
  = 'MEDIUMTEXT' // MYSQL

MEDIUM_SYMBOL
  = 'MEDIUM'

MEMORY_SYMBOL
  = 'MEMORY'

MERGE_SYMBOL
  = 'MERGE'

MESSAGE_TEXT_SYMBOL
  = 'MESSAGE_TEXT'

MICROSECOND_SYMBOL
  = 'MICROSECOND' // MYSQL-FUNC

MID_SYMBOL
  = 'MID' { return identifier.determineFunction('SUBSTRING_SYMBOL'); } // Synonym

MIDDLEINT_SYMBOL
  = 'MIDDLEINT' { return 'MEDIUMINT_SYMBOL'; } // Synonym (for Powerbuilder)

MIGRATE_SYMBOL
  = 'MIGRATE'

MINUTE_MICROSECOND_SYMBOL
  = 'MINUTE_MICROSECOND'

MINUTE_SECOND_SYMBOL
  = 'MINUTE_SECOND'

MINUTE_SYMBOL
  = 'MINUTE'

MIN_ROWS_SYMBOL
  = 'MIN_ROWS'

MIN_SYMBOL
  = 'MIN' { return identifier.determineFunction('MIN_SYMBOL'); } // SQL-2003-N

MODE_SYMBOL
  = 'MODE'

MODIFIES_SYMBOL
  = 'MODIFIES'

MODIFY_SYMBOL
  = 'MODIFY'

MOD_SYMBOL
  = 'MOD'

MONTH_SYMBOL
  = 'MONTH'

MULTILINESTRING_SYMBOL
  = 'MULTILINESTRING' // MYSQL

MULTIPOINT_SYMBOL
  = 'MULTIPOINT' // MYSQL

MULTIPOLYGON_SYMBOL
  = 'MULTIPOLYGON' // MYSQL

MUTEX_SYMBOL
  = 'MUTEX'

MYSQL_ERRNO_SYMBOL
  = 'MYSQL_ERRNO'

NAMES_SYMBOL
  = 'NAMES'

NAME_SYMBOL
  = 'NAME'

NATIONAL_SYMBOL
  = 'NATIONAL'

NATURAL_SYMBOL
  = 'NATURAL'

NCHAR_STRING_SYMBOL
  = 'NCHAR_STRING'

NCHAR_SYMBOL
  = 'NCHAR'

NDB_SYMBOL
  = 'NDB' { return 'NDBCLUSTER_SYMBOL'; } //Synonym

NDBCLUSTER_SYMBOL
  = 'NDBCLUSTER'

NEG_SYMBOL
  = 'NEG'

NEVER_SYMBOL
  = 'NEVER' &{ return options.serverVersion >= 50704; }

NEW_SYMBOL
  = 'NEW'

NEXT_SYMBOL
  = 'NEXT'

NODEGROUP_SYMBOL
  = 'NODEGROUP'

NONE_SYMBOL
  = 'NONE'

NONBLOCKING_SYMBOL
  = 'NONBLOCKING' &{ return 50700 < options.serverVersion && options.serverVersion < 50706; }

NOT_SYMBOL
  = 'NOT' {
      return options.isSqlModeActive('HighNotPrecedence')
        ? 'NOT2_SYMBOL'
        : 'NOT_SYMBOL';
    } // SQL-2003-R

NOT2_SYMBOL
  = NOT_SYMBOL

CONCAT_PIPES_SYMBOL
  = LOGICAL_OR_OPERATOR
  
NOW_SYMBOL
  = 'NOW' { return identifier.determineFunction('NOW_SYMBOL'); }

NO_SYMBOL
  = 'NO'

NO_WAIT_SYMBOL
  = 'NO_WAIT'

NO_WRITE_TO_BINLOG_SYMBOL
  = 'NO_WRITE_TO_BINLOG'

NULL_SYMBOL
  = 'NULL'

NUMBER_SYMBOL
  = 'NUMBER' &{ return options.serverVersion >= 50606; }

NUMERIC_SYMBOL
  = 'NUMERIC'

NVARCHAR_SYMBOL
  = 'NVARCHAR'

OFFLINE_SYMBOL
  = 'OFFLINE'

OFFSET_SYMBOL
  = 'OFFSET'

OLD_PASSWORD_SYMBOL
  = 'OLD_PASSWORD' &{ return options.serverVersion < 50706; }

ON_SYMBOL
  = 'ON'

ONE_SYMBOL
  = 'ONE'

ONLINE_SYMBOL
  = 'ONLINE'

ONLY_SYMBOL
  = 'ONLY' &{ return options.serverVersion >= 50605; }

OPEN_SYMBOL
  = 'OPEN'

OPTIMIZE_SYMBOL
  = 'OPTIMIZE'

OPTIMIZER_COSTS_SYMBOL
  = 'OPTIMIZER_COSTS' &{ return options.serverVersion >= 50706; }

OPTIONS_SYMBOL
  = 'OPTIONS'

OPTION_SYMBOL
  = 'OPTION'

OPTIONALLY_SYMBOL
  = 'OPTIONALLY'

ORDER_SYMBOL
  = 'ORDER'

OR_SYMBOL
  = 'OR'

OUTER_SYMBOL
  = 'OUTER'

OUTFILE_SYMBOL
  = 'OUTFILE'

OUT_SYMBOL
  = 'OUT'

OWNER_SYMBOL
  = 'OWNER'

PACK_KEYS_SYMBOL
  = 'PACK_KEYS'

PAGE_SYMBOL
  = 'PAGE'

PARSER_SYMBOL
  = 'PARSER'

PARTIAL_SYMBOL
  = 'PARTIAL'

PARTITIONING_SYMBOL
  = 'PARTITIONING'

PARTITIONS_SYMBOL
  = 'PARTITIONS'

PARTITION_SYMBOL
  = 'PARTITION'

PASSWORD_SYMBOL
  = 'PASSWORD'

PHASE_SYMBOL
  = 'PHASE'

PLUGINS_SYMBOL
  = 'PLUGINS'

PLUGIN_DIR_SYMBOL
  = 'PLUGIN_DIR' &{ return options.serverVersion >= 50604; } // Internal

PLUGIN_SYMBOL
  = 'PLUGIN'

POINT_SYMBOL
  = 'POINT'

POLYGON_SYMBOL
  = 'POLYGON' // MYSQL

PORT_SYMBOL
  = 'PORT'

POSITION_SYMBOL
  = 'POSITION' { return identifier.determineFunction('POSITION_SYMBOL'); } // SQL-2003-N

PRECEDES_SYMBOL
  = 'PRECEDES' &{ return options.serverVersion >= 50700; }

PRECISION_SYMBOL
  = 'PRECISION'

PREPARE_SYMBOL
  = 'PREPARE'

PRESERVE_SYMBOL
  = 'PRESERVE'

PREV_SYMBOL
  = 'PREV'

PRIMARY_SYMBOL
  = 'PRIMARY'

PRIVILEGES_SYMBOL
  = 'PRIVILEGES'

PROCEDURE_SYMBOL
  = 'PROCEDURE'

PROCESS_SYMBOL
  = 'PROCESS'

PROCESSLIST_SYMBOL
  = 'PROCESSLIST'

PROFILE_SYMBOL
  = 'PROFILE'

PROFILES_SYMBOL
  = 'PROFILES'

PROXY_SYMBOL
  = 'PROXY'

PURGE_SYMBOL
  = 'PURGE'

QUARTER_SYMBOL
  = 'QUARTER'

QUERY_SYMBOL
  = 'QUERY'

QUICK_SYMBOL
  = 'QUICK'

RANGE_SYMBOL
  = 'RANGE'

READS_SYMBOL
  = 'READS'

READ_ONLY_SYMBOL
  = 'READ_ONLY'

READ_SYMBOL
  = 'READ'

READ_WRITE_SYMBOL
  = 'READ_WRITE'

REAL_SYMBOL
  = 'REAL'

REBUILD_SYMBOL
  = 'REBUILD'

RECOVER_SYMBOL
  = 'RECOVER'

REDOFILE_SYMBOL
  = 'REDOFILE' &{ return options.serverVersion < 80000; }

REDO_BUFFER_SIZE_SYMBOL
  = 'REDO_BUFFER_SIZE'

REDUNDANT_SYMBOL
  = 'REDUNDANT'

REFERENCES_SYMBOL
  = 'REFERENCES'

REGEXP_SYMBOL
  = 'REGEXP'

RELAY_SYMBOL
  = 'RELAY'

RELAYLOG_SYMBOL
  = 'RELAYLOG'

RELAY_LOG_FILE_SYMBOL
  = 'RELAY_LOG_FILE'

RELAY_LOG_POS_SYMBOL
  = 'RELAY_LOG_POS'

RELAY_THREAD_SYMBOL
  = 'RELAY_THREAD'

RELEASE_SYMBOL
  = 'RELEASE'

RELOAD_SYMBOL
  = 'RELOAD'

REMOVE_SYMBOL
  = 'REMOVE'

RENAME_SYMBOL
  = 'RENAME'

REORGANIZE_SYMBOL
  = 'REORGANIZE'

REPAIR_SYMBOL
  = 'REPAIR'

REPEATABLE_SYMBOL
  = 'REPEATABLE'

REPEAT_SYMBOL
  = 'REPEAT' { return identifier.determineFunction('REPEAT_SYMBOL'); } // MYSQL-FUNC

REPLACE_SYMBOL
  = 'REPLACE' { return identifier.determineFunction('REPLACE_SYMBOL'); } // MYSQL-FUNC

REPLICATION_SYMBOL
  = 'REPLICATION'

REPLICATE_DO_DB_SYMBOL
  = 'REPLICATE_DO_DB' &{ return options.serverVersion >= 50700; }

REPLICATE_IGNORE_DB_SYMBOL
  = 'REPLICATE_IGNORE_DB' &{ return options.serverVersion >= 50700; }

REPLICATE_DO_TABLE_SYMBOL
  = 'REPLICATE_DO_TABLE' &{ return options.serverVersion >= 50700; }

REPLICATE_IGNORE_TABLE_SYMBOL
  = 'REPLICATE_IGNORE_TABLE' &{ return options.serverVersion >= 50700; }

REPLICATE_WILD_DO_TABLE_SYMBOL
  = 'REPLICATE_WILD_DO_TABLE' &{ return options.serverVersion >= 50700; }

REPLICATE_WILD_IGNORE_TABLE_SYMBOL
  = 'REPLICATE_WILD_IGNORE_TABLE' &{ return options.serverVersion >= 50700; }

REPLICATE_REWRITE_DB_SYMBOL
  = 'REPLICATE_REWRITE_DB' &{ return options.serverVersion >= 50700; }

REQUIRE_SYMBOL
  = 'REQUIRE'

RESET_SYMBOL
  = 'RESET'

RESIGNAL_SYMBOL
  = 'RESIGNAL'

RESTORE_SYMBOL
  = 'RESTORE'

RESTRICT_SYMBOL
  = 'RESTRICT'

RESUME_SYMBOL
  = 'RESUME'

RETURNED_SQLSTATE_SYMBOL
  = 'RETURNED_SQLSTATE'

RETURNS_SYMBOL
  = 'RETURNS'

RETURN_SYMBOL
  = 'RETURN'?

REVERSE_SYMBOL
  = 'REVERSE'

REVOKE_SYMBOL
  = 'REVOKE'

RIGHT_SYMBOL
  = 'RIGHT'

RLIKE_SYMBOL
  = 'RLIKE' { return 'REGEXP_SYMBOL'; } // Synonym (like in mSQL2)

ROLLBACK_SYMBOL
  = 'ROLLBACK'

ROLLUP_SYMBOL
  = 'ROLLUP'

ROTATE_SYMBOL
  = 'ROTATE' &{ return options.serverVersion >= 50713; }

ROUTINE_SYMBOL
  = 'ROUTINE'

ROWS_SYMBOL
  = 'ROWS'

ROW_COUNT_SYMBOL
  = 'ROW_COUNT'

ROW_FORMAT_SYMBOL
  = 'ROW_FORMAT'

ROW_SYMBOL
  = 'ROW'

RTREE_SYMBOL
  = 'RTREE'

SAVEPOINT_SYMBOL
  = 'SAVEPOINT'

SCHEDULE_SYMBOL
  = 'SCHEDULE'

SCHEMA_SYMBOL
  = 'SCHEMA' { return 'DATABASE_SYMBOL'; } // Synonym

SCHEMA_NAME_SYMBOL
  = 'SCHEMA_NAME'

SCHEMAS_SYMBOL
  = 'SCHEMAS' { return 'DATABASES_SYMBOL'; } // Synonym

SECOND_MICROSECOND_SYMBOL
  = 'SECOND_MICROSECOND'

SECOND_SYMBOL
  = 'SECOND'

SECURITY_SYMBOL
  = 'SECURITY'

SELECT_SYMBOL
  = 'SELECT'

SENSITIVE_SYMBOL
  = 'SENSITIVE' // FUTURE-USE

SEPARATOR_SYMBOL
  = 'SEPARATOR'

SERIALIZABLE_SYMBOL
  = 'SERIALIZABLE'

SERIAL_SYMBOL
  = 'SERIAL'

SESSION_SYMBOL
  = 'SESSION'

SERVER_SYMBOL
  = 'SERVER'

SERVER_OPTIONS_SYMBOL
  = 'SERVER_OPTIONS'

SESSION_USER_SYMBOL
  = 'SESSION_USER' { return identifier.determineFunction('USER_SYMBOL'); } // Synonym

SET_SYMBOL
  = 'SET'

SET_VAR_SYMBOL
  = 'SET_VAR'

SHARE_SYMBOL
  = 'SHARE'

SHOW_SYMBOL
  = 'SHOW'

SHUTDOWN_SYMBOL
  = 'SHUTDOWN'

SIGNAL_SYMBOL
  = 'SIGNAL'

SIGNED_SYMBOL
  = 'SIGNED'

SIMPLE_SYMBOL
  = 'SIMPLE'

SLAVE_SYMBOL
  = 'SLAVE'

SLOW_SYMBOL
  = 'SLOW'

SMALLINT_SYMBOL
  = 'SMALLINT'

SNAPSHOT_SYMBOL
  = 'SNAPSHOT'

SOME_SYMBOL
  = 'SOME' { return 'ANY_SYMBOL'; } // Synonym

SOCKET_SYMBOL
  = 'SOCKET'

SONAME_SYMBOL
  = 'SONAME'

SOUNDS_SYMBOL
  = 'SOUNDS'

SOURCE_SYMBOL
  = 'SOURCE'

SPATIAL_SYMBOL
  = 'SPATIAL'

SPECIFIC_SYMBOL
  = 'SPECIFIC'

SQLEXCEPTION_SYMBOL
  = 'SQLEXCEPTION'

SQLSTATE_SYMBOL
  = 'SQLSTATE'

SQLWARNING_SYMBOL
  = 'SQLWARNING'

SQL_AFTER_GTIDS_SYMBOL
  = 'SQL_AFTER_GTIDS' // MYSQL

SQL_AFTER_MTS_GAPS_SYMBOL
  = 'SQL_AFTER_MTS_GAPS' &{ return options.serverVersion >= 50606; } // MYSQL

SQL_BEFORE_GTIDS_SYMBOL
  = 'SQL_BEFORE_GTIDS' // MYSQL

SQL_BIG_RESULT_SYMBOL
  = 'SQL_BIG_RESULT'

SQL_BUFFER_RESULT_SYMBOL
  = 'SQL_BUFFER_RESULT'

SQL_CACHE_SYMBOL
  = 'SQL_CACHE' &{ return options.serverVersion < 80000; }

SQL_CALC_FOUND_ROWS_SYMBOL
  = 'SQL_CALC_FOUND_ROWS'

SQL_NO_CACHE_SYMBOL
  = 'SQL_NO_CACHE'

SQL_SMALL_RESULT_SYMBOL
  = 'SQL_SMALL_RESULT'

SQL_SYMBOL
  = 'SQL'

SQL_THREAD_SYMBOL
  = 'SQL_THREAD'

SSL_SYMBOL
  = 'SSL'

STACKED_SYMBOL
  = 'STACKED' &{ return options.serverVersion >= 50700; }

STARTING_SYMBOL
  = 'STARTING'

STARTS_SYMBOL
  = 'STARTS'

START_SYMBOL
  = 'START'

STATS_AUTO_RECALC_SYMBOL
  = 'STATS_AUTO_RECALC'

STATS_PERSISTENT_SYMBOL
  = 'STATS_PERSISTENT'

STATS_SAMPLE_PAGES_SYMBOL
  = 'STATS_SAMPLE_PAGES'

STATUS_SYMBOL
  = 'STATUS'

STDDEV_SAMP_SYMBOL
  = 'STDDEV_SAMP' { return identifier.determineFunction('STDDEV_SAMP_SYMBOL'); } // SQL-2003-N

STDDEV_SYMBOL
  = 'STDDEV' { return identifier.determineFunction('STD_SYMBOL'); } // Synonym

STDDEV_POP_SYMBOL
  = 'STDDEV_POP' { return identifier.determineFunction('STD_SYMBOL'); } // Synonym

STD_SYMBOL
  = 'STD' { return identifier.determineFunction('STD_SYMBOL'); }

STOP_SYMBOL
  = 'STOP'

STORAGE_SYMBOL
  = 'STORAGE'

STORED_SYMBOL
  = 'STORED' &{ return options.serverVersion >= 50707; }

STRAIGHT_JOIN_SYMBOL
  = 'STRAIGHT_JOIN'

STRING_SYMBOL
  = 'STRING'

SUBCLASS_ORIGIN_SYMBOL
  = 'SUBCLASS_ORIGIN'

SUBDATE_SYMBOL
  = 'SUBDATE' { return identifier.determineFunction('SUBDATE_SYMBOL'); }

SUBJECT_SYMBOL
  = 'SUBJECT'

SUBPARTITIONS_SYMBOL
  = 'SUBPARTITIONS'

SUBPARTITION_SYMBOL
  = 'SUBPARTITION'

SUBSTR_SYMBOL
  =  'SUBSTR' { return identifier.determineFunction('SUBSTRING_SYMBOL'); } // Synonym

SUBSTRING_SYMBOL
  = 'SUBSTRING' { return identifier.determineFunction('SUBSTRING_SYMBOL'); } // SQL-2003-N

SUM_SYMBOL
  = 'SUM' { return identifier.determineFunction('SUM_SYMBOL'); } // SQL-2003-N

SUPER_SYMBOL
  = 'SUPER'

SUSPEND_SYMBOL
  = 'SUSPEND'

SWAPS_SYMBOL
  = 'SWAPS'

SWITCHES_SYMBOL
  = 'SWITCHES'

SYSDATE_SYMBOL
  = 'SYSDATE' { return identifier.determineFunction('SYSDATE_SYMBOL'); }

SYSTEM_USER_SYMBOL
  = 'SYSTEM_USER' { return identifier.determineFunction('USER_SYMBOL'); }

TABLES_SYMBOL
  = 'TABLES'

TABLESPACE_SYMBOL
  = 'TABLESPACE'

TABLE_REF_PRIORITY_SYMBOL
  = 'TABLE_REF_PRIORITY' &{ return options.serverVersion < 80000; }

TABLE_SYMBOL
  = 'TABLE'

TABLE_CHECKSUM_SYMBOL
  = 'TABLE_CHECKSUM'

TABLE_NAME_SYMBOL
  = 'TABLE_NAME'

TEMPORARY_SYMBOL
  = 'TEMPORARY'

TEMPTABLE_SYMBOL
  = 'TEMPTABLE'

TERMINATED_SYMBOL
  = 'TERMINATED'

TEXT_SYMBOL
  = 'TEXT'

THAN_SYMBOL
  = 'THAN'

THEN_SYMBOL
  = 'THEN'

TIMESTAMP_SYMBOL
  = 'TIMESTAMP'

TIMESTAMP_ADD_SYMBOL
  = 'TIMESTAMP_ADD'

TIMESTAMP_DIFF_SYMBOL
  = 'TIMESTAMP_DIFF'

TIME_SYMBOL
  = 'TIME'

TINYBLOB_SYMBOL
  = 'TINYBLOB' // MYSQL

TINYINT_SYMBOL
  = 'TINYINT'

TINYTEXT_SYMBOL
  = 'TINYTEXT' // MYSQL

TO_SYMBOL
  = 'TO'

TRAILING_SYMBOL
  = 'TRAILING'

TRANSACTION_SYMBOL
  = 'TRANSACTION'

TRIGGERS_SYMBOL
  = 'TRIGGERS'

TRIGGER_SYMBOL
  = 'TRIGGER'

TRIM_SYMBOL
  = 'TRIM' { return identifier.determineFunction('TRIM_SYMBOL'); } // SQL-2003-N

TRUE_SYMBOL
  = 'TRUE'

TRUNCATE_SYMBOL
  = 'TRUNCATE'

TYPES_SYMBOL
  = 'TYPES'

TYPE_SYMBOL
  = 'TYPE'

UDF_RETURNS_SYMBOL
  = 'UDF_RETURNS'

UNCOMMITTED_SYMBOL
  = 'UNCOMMITTED'

UNDEFINED_SYMBOL
  = 'UNDEFINED'

UNDOFILE_SYMBOL
  = 'UNDOFILE'

UNDO_BUFFER_SIZE_SYMBOL
  = 'UNDO_BUFFER_SIZE'

UNDO_SYMBOL
  = 'UNDO' // FUTURE-USE

UNICODE_SYMBOL
  = 'UNICODE'

UNINSTALL_SYMBOL
  = 'UNINSTALL'

UNION_SYMBOL
  = 'UNION'

UNIQUE_SYMBOL
  = 'UNIQUE'

UNKNOWN_SYMBOL
  = 'UNKNOWN'

UNLOCK_SYMBOL
  = 'UNLOCK'

UNSIGNED_SYMBOL
  = 'UNSIGNED' // MYSQL

UNTIL_SYMBOL
  = 'UNTIL'

UPDATE_SYMBOL
  = 'UPDATE'

UPGRADE_SYMBOL
  = 'UPGRADE'

USAGE_SYMBOL
  = 'USAGE'

USER_RESOURCES_SYMBOL
  = 'USER_RESOURCES'

USER_SYMBOL
  = 'USER'

USE_FRM_SYMBOL
  = 'USE_FRM'

USE_SYMBOL
  = 'USE'

USING_SYMBOL
  = 'USING'

UTC_DATE_SYMBOL
  = 'UTC_DATE'

UTC_TIMESTAMP_SYMBOL
  = 'UTC_TIMESTAMP'

UTC_TIME_SYMBOL
  = 'UTC_TIME'

VALIDATION_SYMBOL
  = 'VALIDATION' &{ return options.serverVersion >= 50706; }

VALUES_SYMBOL
  = 'VALUES'

VALUE_SYMBOL
  = 'VALUE'

VARBINARY_SYMBOL
  = 'VARBINARY'

VARCHAR_SYMBOL
  = 'VARCHAR'

VARCHARACTER_SYMBOL
  = 'VARCHARACTER' { return 'VARCHAR_SYMBOL'; } // Synonym

VARIABLES_SYMBOL
  = 'VARIABLES'

VARIANCE_SYMBOL
  = 'VARIANCE' { return identifier.determineFunction('VARIANCE_SYMBOL'); }

VARYING_SYMBOL
  = 'VARYING'

VAR_POP_SYMBOL
  = 'VAR_POP' { return identifier.determineFunction('VARIANCE_SYMBOL'); } // Synonym

VAR_SAMP_SYMBOL
  = 'VAR_SAMP' { return identifier.determineFunction('VAR_SAMP_SYMBOL'); }

VIEW_SYMBOL
  = 'VIEW'

VIRTUAL_SYMBOL
  = 'VIRTUAL' &{ return options.serverVersion >= 50707; }

WAIT_SYMBOL
  = 'WAIT'

WARNINGS_SYMBOL
  = 'WARNINGS'

WEEK_SYMBOL
  = 'WEEK'

WEIGHT_STRING_SYMBOL
  = 'WEIGHT_STRING'

WHEN_SYMBOL
  = 'WHEN'

WHERE_SYMBOL
  = 'WHERE'

WHILE_SYMBOL
  = 'WHILE'

WITH_SYMBOL
  = 'WITH'

WITHOUT_SYMBOL
  = 'WITHOUT'

WORK_SYMBOL
  = 'WORK'

WRAPPER_SYMBOL
  = 'WRAPPER'

WRITE_SYMBOL
  = 'WRITE'

X509_SYMBOL
  = 'X509'

XA_SYMBOL
  = 'XA'

XID_SYMBOL
  = 'XID' &{ return options.serverVersion >= 50704; }

XML_SYMBOL
  = 'XML'

XOR_SYMBOL
  = 'XOR'

YEAR_MONTH_SYMBOL
  = 'YEAR_MONTH'

YEAR_SYMBOL
  = 'YEAR'

ZEROFILL_SYMBOL
  = 'ZEROFILL' // MYSQL

PERSIST_SYMBOL
  = 'PERSIST' &{ return options.serverVersion >= 80000; }

ROLE_SYMBOL
  = 'ROLE' &{ return options.serverVersion >= 80000; } // SQL-1999-R

ADMIN_SYMBOL
  = 'ADMIN' &{ return options.serverVersion >= 80000; } // SQL-1999-R

INVISIBLE_SYMBOL
  = 'INVISIBLE' &{ return options.serverVersion >= 80000; }

VISIBLE_SYMBOL
  = 'VISIBLE' &{ return options.serverVersion >= 80000; }

EXCEPT_SYMBOL
  = 'EXCEPT' &{ return options.serverVersion >= 80000; } // SQL-1999-R

COMPONENT_SYMBOL
  = 'COMPONENT' &{ return options.serverVersion >= 80000; } // MYSQL

RECURSIVE_SYMBOL
  = 'RECURSIVE' &{ return options.serverVersion >= 80000; } // SQL-1999-R

JSON_OBJECTAGG_SYMBOL
  = 'JSON_OBJECTAGG' &{ return options.serverVersion >= 80000; } // SQL-2015-R

JSON_ARRAYAGG_SYMBOL
  = 'JSON_ARRAYAGG' &{ return options.serverVersion >= 80000; } // SQL-2015-R

OF_SYMBOL
  = 'OF' &{ return options.serverVersion >= 80000; } // SQL-1999-R

SKIP_SYMBOL
  = 'SKIP' &{ return options.serverVersion >= 80000; } // MYSQL

LOCKED_SYMBOL
  = 'LOCKED' &{ return options.serverVersion >= 80000; } // MYSQL

NOWAIT_SYMBOL
  = 'NOWAIT' &{ return options.serverVersion >= 80000; } // MYSQL

GROUPING_SYMBOL
  = 'GROUPING' &{ return options.serverVersion >= 80000; } // SQL-2011-R

PERSIST_ONLY_SYMBOL
  = 'PERSIST_ONLY' &{ return options.serverVersion >= 80000; } // MYSQL

HISTOGRAM_SYMBOL
  = 'HISTOGRAM' &{ return options.serverVersion >= 80000; } // MYSQL

BUCKETS_SYMBOL
  = 'BUCKETS' &{ return options.serverVersion >= 80000; } // MYSQL

REMOTE_SYMBOL
  = 'REMOTE' &{ return options.serverVersion >= 80003 && options.serverVersion < 80014; } // MYSQL

CLONE_SYMBOL
  = 'CLONE' &{ return options.serverVersion >= 80000; } // MYSQL

CUME_DIST_SYMBOL
  = 'CUME_DIST' &{ return options.serverVersion >= 80000; } // SQL-2003-R

DENSE_RANK_SYMBOL
  = 'DENSE_RANK' &{ return options.serverVersion >= 80000; } // SQL-2003-R

EXCLUDE_SYMBOL
  = 'EXCLUDE' &{ return options.serverVersion >= 80000; } // SQL-2003-N

FIRST_VALUE_SYMBOL
  = 'FIRST_VALUE' &{ return options.serverVersion >= 80000; } // SQL-2011-R

FOLLOWING_SYMBOL
  = 'FOLLOWING' &{ return options.serverVersion >= 80000; } // SQL-2003-N

GROUPS_SYMBOL
  = 'GROUPS' &{ return options.serverVersion >= 80000; } // SQL-2011-R

LAG_SYMBOL
  = 'LAG' &{ return options.serverVersion >= 80000; } // SQL-2011-R

LAST_VALUE_SYMBOL
  = 'LAST_VALUE' &{ return options.serverVersion >= 80000; } // SQL-2011-R

LEAD_SYMBOL
  = 'LEAD' &{ return options.serverVersion >= 80000; } // SQL-2011-R

NTH_VALUE_SYMBOL
  = 'NTH_VALUE' &{ return options.serverVersion >= 80000; } // SQL-2011-R

NTILE_SYMBOL
  = 'NTILE' &{ return options.serverVersion >= 80000; } // SQL-2011-R

NULLS_SYMBOL
  = 'NULLS' &{ return options.serverVersion >= 80000; } // SQL-2003-N

OTHERS_SYMBOL
  = 'OTHERS' &{ return options.serverVersion >= 80000; } // SQL-2003-N

OVER_SYMBOL
  = 'OVER' &{ return options.serverVersion >= 80000; } // SQL-2003-R

PERCENT_RANK_SYMBOL
  = 'PERCENT_RANK' &{ return options.serverVersion >= 80000; } // SQL-2003-R

PRECEDING_SYMBOL
  = 'PRECEDING' &{ return options.serverVersion >= 80000; } // SQL-2003-N

RANK_SYMBOL
  = 'RANK' &{ return options.serverVersion >= 80000; } // SQL-2003-R

RESPECT_SYMBOL
  = 'RESPECT' &{ return options.serverVersion >= 80000; } // SQL_2011-N

ROW_NUMBER_SYMBOL
  = 'ROW_NUMBER' &{ return options.serverVersion >= 80000; } // SQL-2003-R

TIES_SYMBOL
  = 'TIES' &{ return options.serverVersion >= 80000; } // SQL-2003-N

UNBOUNDED_SYMBOL
  = 'UNBOUNDED' &{ return options.serverVersion >= 80000; } // SQL-2003-N

WINDOW_SYMBOL
  = 'WINDOW' &{ return options.serverVersion >= 80000; } // SQL-2003-R

EMPTY_SYMBOL
  = 'EMPTY' &{ return options.serverVersion >= 80000; } // SQL-2016-R

JSON_TABLE_SYMBOL
  = 'JSON_TABLE' &{ return options.serverVersion >= 80000; } // SQL-2016-R

NESTED_SYMBOL
  = 'NESTED' &{ return options.serverVersion >= 80000; } // SQL-2016-N

ORDINALITY_SYMBOL
  = 'ORDINALITY' &{ return options.serverVersion >= 80000; } // SQL-2003-N

PATH_SYMBOL
  = 'PATH' &{ return options.serverVersion >= 80000; } // SQL-2003-N

HISTORY_SYMBOL
  = 'HISTORY' &{ return options.serverVersion >= 80000; } // MYSQL

REUSE_SYMBOL
  = 'REUSE' &{ return options.serverVersion >= 80000; } // MYSQL

SRID_SYMBOL
  = 'SRID' &{ return options.serverVersion >= 80000; } // MYSQL

THREAD_PRIORITY_SYMBOL
  = 'THREAD_PRIORITY' &{ return options.serverVersion >= 80000; } // MYSQL

RESOURCE_SYMBOL
  = 'RESOURCE' &{ return options.serverVersion >= 80000; } // MYSQL

SYSTEM_SYMBOL
  = 'SYSTEM' &{ return options.serverVersion >= 80000; } // SQL-2003-R

VCPU_SYMBOL
  = 'VCPU' &{ return options.serverVersion >= 80000; } // MYSQL

MASTER_PUBLIC_KEY_PATH_SYMBOL
  = 'MASTER_PUBLIC_KEY_PATH' &{ return options.serverVersion >= 80000; } // MYSQL

GET_MASTER_PUBLIC_KEY_SYMBOL
  = 'GET_MASTER_PUBLIC_KEY_SYM' &{ return options.serverVersion >= 80000; } // MYSQL

RESTART_SYMBOL
  = 'RESTART' &{ return options.serverVersion >= 80011; } // SQL-2003-N

DEFINITION_SYMBOL
  = 'DEFINITION' &{ return options.serverVersion >= 80011; } // MYSQL

DESCRIPTION_SYMBOL
  = 'DESCRIPTION' &{ return options.serverVersion >= 80011; } // MYSQL

ORGANIZATION_SYMBOL
  = 'ORGANIZATION' &{ return options.serverVersion >= 80011; } // MYSQL

REFERENCE_SYMBOL
  = 'REFERENCE' &{ return options.serverVersion >= 80011; } // MYSQL

OPTIONAL_SYMBOL
  = 'OPTIONAL' &{ return options.serverVersion >= 80013; } // MYSQL

SECONDARY_SYMBOL
  = 'SECONDARY' &{ return options.serverVersion >= 80013; } // MYSQL

SECONDARY_ENGINE_SYMBOL
  = 'SECONDARY_ENGINE' &{ return options.serverVersion >= 80013; } // MYSQL

SECONDARY_LOAD_SYMBOL
  = 'SECONDARY_LOAD' &{ return options.serverVersion >= 80013; } // MYSQL

SECONDARY_UNLOAD_SYMBOL
  = 'SECONDARY_UNLOAD' &{ return options.serverVersion >= 80013; } // MYSQL

ACTIVE_SYMBOL
  = 'ACTIVE' &{ return options.serverVersion >= 80014; } // MYSQL

INACTIVE_SYMBOL
  = 'INACTIVE' &{ return options.serverVersion >= 80014; } // MYSQL

LATERAL_SYMBOL
  = 'LATERAL' &{ return options.serverVersion >= 80014; } // SQL-2003-R

RETAIN_SYMBOL
  = 'RETAIN' &{ return options.serverVersion >= 80014; } // MYSQL

OLD_SYMBOL
  = 'OLD' &{ return options.serverVersion >= 80014; } // SQL-2003-R

NETWORK_NAMESPACE_SYMBOL
  = 'NETWORK_NAMESPACE' &{ return options.serverVersion >= 80017; } // MYSQL

ENFORCED_SYMBOL
  = 'ENFORCED' &{ return options.serverVersion >= 80017; } // SQL-2003-N

ARRAY_SYMBOL
  = 'ARRAY' &{ return options.serverVersion >= 80017; } // SQL-2003-R

OJ_SYMBOL
  = 'OJ' &{ return options.serverVersion >= 80017; } // ODBC

MEMBER_SYMBOL
  = 'MEMBER' &{ return options.serverVersion >= 80017; } // SQL-2003-R

RANDOM_SYMBOL
  = 'RANDOM' &{ return options.serverVersion >= 80018; } // MYSQL

MASTER_COMPRESSION_ALGORITHM_SYMBOL
  = 'MASTER_COMPRESSION_ALGORITHM' &{ return options.serverVersion >= 80018; } // MYSQL

MASTER_ZSTD_COMPRESSION_LEVEL_SYMBOL
  = 'MASTER_ZSTD_COMPRESSION_LEVEL' &{ return options.serverVersion >= 80018; } // MYSQL

PRIVILEGE_CHECKS_USER_SYMBOL
  = 'PRIVILEGE_CHECKS_USER' &{ return options.serverVersion >= 80018; } // MYSQL

MASTER_TLS_CIPHERSUITES_SYMBOL
  = 'MASTER_TLS_CIPHERSUITES' &{ return options.serverVersion >= 80018; } // MYSQL

REQUIRE_ROW_FORMAT_SYMBOL
  = 'REQUIRE_ROW_FORMAT' &{ return options.serverVersion >= 80019; } // MYSQL

PASSWORD_LOCK_TIME_SYMBOL
  = 'PASSWORD_LOCK_TIME' &{ return options.serverVersion >= 80019; } // MYSQL

FAILED_LOGIN_ATTEMPTS_SYMBOL
  = 'FAILED_LOGIN_ATTEMPTS' &{ return options.serverVersion >= 80019; } // MYSQL

REQUIRE_TABLE_PRIMARY_KEY_CHECK_SYMBOL
  = 'REQUIRE_TABLE_PRIMARY_KEY_CHECK' &{ return options.serverVersion >= 80019; } // MYSQL

STREAM_SYMBOL
  = 'STREAM' &{ return options.serverVersion >= 80019; } // MYSQL

OFF_SYMBOL
  = 'OFF' &{ return options.serverVersion >= 80019; } // SQL-1999-R

INT1_SYMBOL
  = 'INT1' { return 'TINYINT_SYMBOL'; }   // Synonym

INT2_SYMBOL
  = 'INT2' { return 'SMALLINT_SYMBOL'; }  // Synonym

INT3_SYMBOL
  = 'INT3' { return 'MEDIUMINT_SYMBOL'; } // Synonym

INT4_SYMBOL
  = 'INT4' { return 'INT_SYMBOL'; }       // Synonym

INT8_SYMBOL
  = 'INT8' { return 'BIGINT_SYMBOL'; }    // Synonym

SQL_TSI_SECOND_SYMBOL
  = 'SQL_TSI_SECOND' { return 'SECOND_SYMBOL'; }  // Synonym

SQL_TSI_MINUTE_SYMBOL
  = 'SQL_TSI_MINUTE' { return 'MINUTE_SYMBOL'; }  // Synonym

SQL_TSI_HOUR_SYMBOL
  = 'SQL_TSI_HOUR' { return 'HOUR_SYMBOL'; }    // Synonym

SQL_TSI_DAY_SYMBOL
  = 'SQL_TSI_DAY' { return 'DAY_SYMBOL'; }     // Synonym

SQL_TSI_WEEK_SYMBOL
  = 'SQL_TSI_WEEK' { return 'WEEK_SYMBOL'; }    // Synonym

SQL_TSI_MONTH_SYMBOL
  = 'SQL_TSI_MONTH' { return 'MONTH_SYMBOL'; }   // Synonym

SQL_TSI_QUARTER_SYMBOL
  = 'SQL_TSI_QUARTER' { return 'QUARTER_SYMBOL'; } // Synonym

SQL_TSI_YEAR_SYMBOL
  = 'SQL_TSI_YEAR' { return 'YEAR_SYMBOL'; }    // Synonym

WHITESPACE
  = [ \t\f\r\n]* { return ''; }

INVALID_INPUT
  = [\u0001-\u0008]   // Control codes.
  / '\u000B'        // Line tabulation.
  / '\u000C'        // Form feed.
  / [\u000E-\u001F] // More control codes.
  / '['
  / ']'

EOF
  = !.
