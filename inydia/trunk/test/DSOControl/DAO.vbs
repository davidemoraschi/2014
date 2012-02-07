Const dbInteger = 3
Const dbText = 10
Const dbLong = 4
Const dbAutoIncrField = 16
Const dbDate = 8
Const dbMemo = 12
Const dbRelationUpdateCascade = 256
Const dbRelationDeleteCascade = 4096
Const dbLangSpanish = ";LANGID=0x0409;CP=1252;COUNTRY=0" 'DAO.LanguageConstants

Sub Create_MDB_File(strFilePath)
	Set DAODbs = CreateObject("DAO.DBEngine.36")
    With DAODbs
	    Set DAOdb = .CreateDatabase(strFilePath, dbLangSpanish)
	    DAOdb.Close
	    Set DAOdb = Nothing
    End With
	Set DAODbs = Nothing
End Sub

Sub LoopThruFields(ByVAl TblName, ByVal iLevel, ByVal adoRS, ByVal DAOdb, ByVal ForeignKey)
    iLevel = iLevel + 1
    PriorLevel = iLevel
    
    Set Tbl = DAOdb.CreateTableDef(TblName)
    With Tbl
        Set Fld = .CreateField(TblName & "_ID", 4)
        Fld.attributes = dbAutoIncrField
        .Fields.Append(Fld)
        Set ind = .CreateIndex("PK_" & TblName)
        With ind
	        .Fields.Append(.CreateField(TblName & "_ID"))
	        .Unique = True
	        .Primary = True
        End With
        .Indexes.Append(ind)
        .Indexes.Refresh
        Set ind = Nothing
	
        If PriorLevel > 1 Then
	        Set Fld = .CreateField(ForeignKey & "_ID", 4)
	        .Fields.Append(Fld)
	        Set ind = .CreateIndex("FK_" & ForeignKey)
	        With ind
		        .Fields.Append(.CreateField(ForeignKey & "_ID"))
		        .Unique = False
		        .Primary = False
	        End With
	        Tbl.Indexes.Append(ind)
	        Tbl.Indexes.Refresh
	        Set ind = Nothing		
        End If
        cnt = adoRS.Fields.Count - 1
        For ndx = 0 To cnt
            With adoRS.Fields(ndx)
            If .Name <> "$Text" Then
                If .Type = adChapter Then
                    Set adoChildRS = .Value
		            ChildTable = .Name
                    Call LoopThruFields (ChildTable, iLevel, adoChildRS, DAOdb, TblName)
                Else
                    'WScript.Echo iLevel & ": adoRS.Fields(" & ndx & ") = " & .Name & " = " & .Value & " : " & .Type
                    Stop
                    Set Fld = Tbl.CreateField(.Name, .Type)                   
                    Tbl.Fields.Append(Fld)
                End If
            End If
            End With
        Next 'ndx

        'On Error Resume Next 'Hay tablas vacías
        DAOdb.TableDefs.Append Tbl
        'On Error Goto 0
        iLevel = PriorLevel
    End With

    Set Fld = Nothing
    Set Tbl = Nothing
End Sub

Sub LoopThruRela(ByVAl TblName, ByVal iLevel, ByVal adoRS, ByVal DAOdb, ByVal ForeignKey)
    iLevel = iLevel + 1
    PriorLevel = iLevel
    
	If PriorLevel > 1 Then
	    Set rel = DAOdb.CreateRelation(ForeignKey & "_" & TblName)
	    With rel
		    'Specify the primary table.
		    .Table = ForeignKey
		    'Specify the related table.
		    .ForeignTable = TblName
		    'Specify attributes for cascading updates and deletes.
		    .attributes = dbRelationUpdateCascade + dbRelationDeleteCascade					
		    'Add the fields to the relation.
		    'Field name in primary table.
		    Set Fld = .CreateField(ForeignKey & "_ID")
		    'Field name in related table.
		    Fld.ForeignName = ForeignKey & "_ID"
		    'Append the field.
		    .Fields.Append Fld
		    'Repeat for other fields if a multi-field relation.
	    End With
	    DAOdb.Relations.Append rel
	End If

    cnt = adoRS.Fields.Count - 1
    For ndx = 0 To cnt
        With adoRS.Fields(ndx)
            If .Name <> "$Text" Then
                If .Type = adChapter Then
                    Set adoChildRS = .Value
		            ChildTable = .Name
                    Call LoopThruRela (ChildTable, iLevel, adoChildRS, DAOdb, TblName)
                End If
            End If
        End With
    Next 'ndx
    iLevel = PriorLevel
End Sub

Sub LoopThruData(ByVAl TblName, ByVal iLevel, ByVal adoRS, ByVal DAOdb, ByVal ForeignKey, ByVal ForeignKeyValue)
    iLevel = iLevel + 1
    PriorLevel = iLevel

    Set DAOrs = DAOdb.OpenRecordset(TblName)
    
    'adoRS.MoveFirst
    cnt = adoRS.Fields.Count - 1
    While Not adoRS.EOF
    'Stop
        DAOrs.AddNew
        autoKey = DAOrs(TblName & "_ID")
	    If PriorLevel > 1 Then
            DAOrs(ForeignKey) = ForeignKeyValue
	    End If
        For ndx = 0 To cnt
            With adoRS.Fields(ndx)
                If .Name <> "$Text" Then
                    If .Type = adChapter Then
                        Set adoChildRS = .Value
		                ChildTable = .Name
                        Call LoopThruData (ChildTable, iLevel, adoChildRS, DAOdb, TblName & "_ID", autoKey)
                    Else
                        'WScript.Echo iLevel & ": adoRS.Fields(" & ndx & ") = " & .Name & " = " & .Value & " : " & .Type
                        'Stop
                        DAOrs(.Name) = .Value
                        'Set Fld = Tbl.CreateField(.Name, .Type)                   
                        'Tbl.Fields.Append(Fld)
                    End If
                End If
            End With
        Next 'ndx
        DAOrs.Update
        adoRS.MoveNext
        'DAOrs.AddNew
    Wend

    'DAOrs.Update
    iLevel = PriorLevel
'Stop
    Set DAOrs = Nothing
End Sub
