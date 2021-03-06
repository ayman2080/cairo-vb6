VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cLiquidacionFormula"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements CSInterfacesABM.cIEditGeneric
Implements CSInterfacesABM.cIABMClient
Implements CSMenu.cIMenuClient
Implements CSInterfacesABM.cIABMClientGrid

'--------------------------------------------------------------------------------
' cLiquidacionFormula
' 12-08-08

'--------------------------------------------------------------------------------
' notas:
'--------------------------------------------------------------------------------
' api win32
    ' constantes
    ' estructuras
    ' funciones

'--------------------------------------------------------------------------------

' constantes
Private Const C_Module = "cLiquidacionFormula"

Private Const K_NOMBRE      As Integer = 1
Private Const K_CODIGO      As Integer = 2
Private Const K_DESCRIP     As Integer = 3
Private Const K_ACTIVO      As Integer = 4
Private Const K_FORMULA     As Integer = 5

Private Const K_ITEMS       As Integer = 7

Private Const KI_LIQFI_ID       As Integer = 1
Private Const KI_CODIGO         As Integer = 2
Private Const KI_NOMBRE         As Integer = 3
Private Const KI_DESCRIP        As Integer = 4
Private Const KI_NOMBRERECIBO   As Integer = 5
Private Const KI_FORMULA        As Integer = 6
Private Const KI_LIQCT_ID       As Integer = 7

' estructuras
' Seudo - Variables
Private c_ErrorSave         As String

' variables privadas
Private m_Id                As Long
Private m_Nombre            As String
Private m_Codigo            As String
Private m_Descrip           As String
Private m_formula           As String
Private m_Activo            As Boolean

' HOJO HASTA ACA

Private m_Editing           As Boolean

Private m_ObjAbm            As cIABMGeneric
Private m_ObjTree           As Object

Private m_IsNew             As Boolean

Private m_BranchId          As Long
Private m_TreeId            As Long

Private m_Host              As CSMenu.cIMenuHost
Private m_Copy              As Boolean


Private m_ItemsDeletedItems            As String
' Properties publicas

Public Property Get ID() As Long
  ID = m_Id
End Property

Public Property Get Nombre() As String
  Nombre = m_Nombre
End Property

Public Property Get Codigo() As String
  Codigo = m_Codigo
End Property

' Properties privadas
' funciones publicas

' Implementacion de cIABMClient
Private Function cIABMClient_Copy() As Boolean
  
  cIABMClient_Terminate
  m_IsNew = True
  
  With m_ObjAbm.Properties(cscLiqfCodigo)
    .Value = C_C & .Value
  End With
  
'  With m_ObjAbm.Properties(cscPaNombre)
'    .Value = C_CopiaDe & .Value
'  End With
  
  m_ObjAbm.ShowValue m_ObjAbm.Properties(cscLiqfCodigo)
  m_ObjAbm.ShowValue m_ObjAbm.Properties(cscLiqfNombre)
  
  m_Copy = True
End Function

Private Function cIABMClient_EditNew() As Boolean
  
  cIABMClient_Terminate
  m_IsNew = True
  
  cIEditGeneric_Edit csNO_ID
End Function

Private Property Get cIABMClient_Aplication() As String
    cIABMClient_Aplication = gAppName
End Property

Private Property Get cIABMClient_CanAddDocDigital() As Boolean
  cIABMClient_CanAddDocDigital = m_Id <> csNO_ID
End Property

Private Property Get cIABMClient_CanCopy() As Boolean
  cIABMClient_CanCopy = True
End Property

Private Property Get cIABMClient_CanNew() As Boolean
  cIABMClient_CanNew = True
End Property

Private Function cIABMClient_ShowDocDigital() As Boolean
  On Error GoTo ControlError
  
  If m_Id = csNO_ID Then Exit Function
  
  Dim Doc As cDocDigital
  Set Doc = New cDocDigital

  Doc.ClientTable = csTLiquidacionFormula
  Doc.ClientTableID = m_Id

  cIABMClient_ShowDocDigital = Doc.ShowDocs(gDB)

  GoTo ExitProc
ControlError:
  MngError Err, C_ShowDocDigital, C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

Private Function cIABMClient_MessageEx(ByVal MessageID As Long, ByVal Info As Variant) As Variant
  Select Case MessageID
  
    Case MSG_DOC_INFO
    
      Dim AbmGen As cABMGeneric
      Set AbmGen = m_ObjAbm
      
      CSKernelClient2.ShowHelp AbmGen.hWnd, _
                               vbNullString, _
                               vbNullString, _
                               csPrePNewLiquidacionFormula
      cIABMClient_MessageEx = MSG_DOC_INFO_HANDLED
    
    Case MSG_GRID_ROW_CHANGE
      If Info Is Nothing Then Exit Function
      
      Dim Row      As cIABMGridRow
      Dim iProp    As cIABMProperty
      Dim Aplicado As Double
      
      Set iProp = Info
      
      Select Case iProp.Key
        Case K_ITEMS
          Set Row = iProp.Grid.Rows(iProp.SelectedIndex)
          
          If Not Row Is Nothing Then
            Set iProp = m_ObjAbm.Properties.Item(cscLiqfiDescrip)
            iProp.Value = pCell(Row, KI_DESCRIP).Value
            m_ObjAbm.ShowValue iProp
            Set iProp = m_ObjAbm.Properties.Item(cscLiqfiFormula)
            iProp.Value = pCell(Row, KI_FORMULA).Value
            m_ObjAbm.ShowValue iProp
          Else
            Set iProp = m_ObjAbm.Properties.Item(cscLiqfiDescrip)
            iProp.Value = vbNullString
            m_ObjAbm.ShowValue iProp
            Set iProp = m_ObjAbm.Properties.Item(cscLiqfiFormula)
            iProp.Value = vbNullString
            m_ObjAbm.ShowValue iProp
          End If
          
      End Select
    
    Case Else
      cIABMClient_MessageEx = True
  End Select
End Function

Private Sub cIABMClient_DiscardChanges()
    LoadCollection
End Sub

Private Function cIABMClient_ListAdHock(List As CSInterfacesABM.cIABMList) As Boolean

End Function

Private Sub cIABMClient_Load()

End Sub

Private Function cIABMClient_PropertyChange(ByVal Clave As Integer) As Boolean

End Function

Private Function cIABMClient_Save() As Boolean
  Dim LastId      As Long
  Dim register    As cRegister
  Dim fields      As cFields
  
  Set register = New cRegister
  Set fields = register.fields
  
  With register
    .fieldId = cscLiqfId
    .Table = csTLiquidacionFormula
  
    If m_Copy Then
      .ID = csNew
    Else
      .ID = m_Id
    End If
  End With

  Dim IProperty As cIABMProperty
  For Each IProperty In m_ObjAbm.Properties
    With IProperty
      Select Case .Key
        Case K_NOMBRE
          fields.Add2 cscLiqfNombre, .Value, csText
        Case K_CODIGO
          fields.Add2 cscLiqfCodigo, .Value, csText
        Case K_DESCRIP
          fields.Add2 cscLiqfDescrip, .Value, csText
        Case K_FORMULA
          fields.Add2 cscLiqfFormula, .Value, csText
        Case K_ACTIVO
          fields.Add2 cscActivo, .Value, csBoolean
      End Select
    End With
  Next
  
  fields.HaveLastUpdate = True
  fields.HaveWhoModify = True
  
  If Not register.BeginTrans(gDB) Then Exit Function
  
  If Not gDB.SaveEx(register, , _
                    cscLiqfCodigo, _
                    C_ABMClientSave, _
                    C_Module, _
                    c_ErrorSave) Then Exit Function
  
  LastId = m_Id
  m_Id = register.ID
  
  If Not pSaveItems() Then GoTo SaveError
  
  If Not register.CommitTrans() Then GoTo SaveError
  
  m_Copy = False
  cIABMClient_Save = Load(register.ID)
  
  Exit Function
SaveError:

  m_Id = LastId
End Function

Private Function cIABMClient_Terminate() As Boolean
    m_Editing = False
    
    cIABMClient_Terminate = True
    ' Este objeto puede no cumplir con la interfaz esperada, asi que si hay un error no
    ' le doy bola
    On Error GoTo ControlError
    If m_Id = csNO_ID Then Exit Function
    If m_ObjTree Is Nothing Then Exit Function
    
    If m_IsNew Then
        m_ObjTree.AddLeave m_Id, m_BranchId, m_TreeId
    Else
        m_ObjTree.AddEditedId m_Id
        m_ObjTree.RefreshActiveBranch
    End If
ControlError:
End Function

Private Property Get cIABMClient_Title() As String
                             'Formulas de Liquidación
  cIABMClient_Title = LNGGetText(4564, vbNullString)
End Property

Private Function cIABMClient_Validate() As Boolean

  Dim IProperty As cIABMProperty

  For Each IProperty In m_ObjAbm.Properties
    With IProperty
      Select Case .Key
        Case K_NOMBRE
          If ValEmpty(.Value, csText) Then
            MsgInfo C_DebeIndicarNombre
            Exit Function
          End If
        Case K_CODIGO
          If ValEmpty(.Value, csText) Then
            .Value = c_get_codigo_from_id
          End If

      End Select
    End With
  Next

  cIABMClient_Validate = True
End Function

' Implementacion de cIEditGeneric
Private Property Get cIEditGeneric_ObjAbm() As CSInterfacesABM.cIABMGeneric
  Set cIEditGeneric_ObjAbm = m_ObjAbm
End Property

Private Function cIEditGeneric_TabClick(ByVal Index As Integer) As Boolean

End Function

Private Property Let cIEditGeneric_TreeId(ByVal rhs As Long)
    m_TreeId = rhs
End Property

Private Property Get cIEditGeneric_TreeId() As Long
    cIEditGeneric_TreeId = m_TreeId
End Property

Private Function cIEditGeneric_GridAdd(ByVal ClavePropiedad As Integer) As Boolean

End Function

Private Function cIEditGeneric_GridEdit(ByVal ClavePropiedad As Integer) As Boolean

End Function

Private Function cIEditGeneric_GridRemove(ByVal ClavePropiedad As Integer) As Boolean

End Function

Private Function cIEditGeneric_ShowList() As Boolean
    cIEditGeneric_ShowList = SecurityCanAccess(csPrePListLiquidacionFormula)
End Function

Private Property Set cIEditGeneric_ObjAbm(rhs As CSInterfacesABM.cIABMGeneric)
    Set m_ObjAbm = rhs
End Property

Private Property Get cIEditGeneric_Editing() As Boolean
    cIEditGeneric_Editing = m_Editing
End Property

Private Function cIEditGeneric_Delete(ID As Long) As Boolean
    If Not SecurityCanAccess(csPrePDeleteLiquidacionFormula) Then Exit Function

    Dim sqlstmt As String
    
    sqlstmt = "delete LiquidacionFormulaItem where liqf_id = " & ID
    sqlstmt = sqlstmt & " delete LiquidacionFormula where liqf_id = " & ID
    
    cIEditGeneric_Delete = gDB.Execute(sqlstmt, C_EditGenericDelete, C_Module)
End Function

Private Function cIEditGeneric_Search(ID As Long, Cancela As Boolean) As Boolean

End Function

Private Function cIEditGeneric_Edit(ID As Long, Optional ByVal InModalWindow As Boolean) As Boolean
  On Error GoTo ControlError
  
  If ID = csNO_ID Then
    m_IsNew = True
    If Not SecurityCanAccess(csPrePNewLiquidacionFormula) Then Exit Function
  Else
    m_IsNew = False
    If Not SecurityCanAccess(csPrePEditLiquidacionFormula) Then Exit Function
  End If

  m_ObjAbm.InModalWindow = InModalWindow
  
  If Not Load(ID) Then Exit Function
  
  If Not LoadCollection() Then Exit Function
  
  m_Editing = True
  m_Copy = False

  If InModalWindow Then
    cIEditGeneric_Edit = m_Id <> csNO_ID
  Else
    cIEditGeneric_Edit = True
  End If

  Exit Function
ControlError:
  MngError Err, C_EditGenericEdit, C_Module, vbNullString
End Function

Private Function cIEditGeneric_PrintObj(ByVal ID As Long) As Boolean

End Function

Private Property Set cIEditGeneric_ObjTree(rhs As Object)
    Set m_ObjTree = rhs
End Property

Private Property Let cIEditGeneric_BranchId(ByVal rhs As Long)
    m_BranchId = rhs
End Property

Private Property Get cIEditGeneric_BranchId() As Long
    cIEditGeneric_BranchId = m_BranchId
End Property

Private Function cIEditGeneric_Preview(ByVal ID As Long) As Boolean

End Function

Private Function cIEditGeneric_PropertyChange(ByVal Key As Integer) As Boolean

End Function

Private Function cIMenuClient_Initialize(F As Object, Host As CSMenu.cIMenuHost) As Boolean
  On Error GoTo ControlError

  Set m_Host = Host
  
  m_Host.Server.AddMenu C_MenuManejoPersonal, csMenuConfigMPersonal, C_MenuConfig, 0, True, False, False, False, True, Nothing
  m_Host.Server.AddMenu C_MenuSueldos, csMenuConfigSueldos, C_MenuManejoPersonal, 0, True, False, False, False, True, Nothing
                            '&Formulas de Liquidación
  m_Host.Server.AddMenu LNGGetText(4565, vbNullString), csPrePListLiquidacionFormula, C_MenuSueldos, 0, True, False, False, False, False, Me
  
  cIMenuClient_Initialize = True
  
  GoTo ExitProc
ControlError:
  MngError Err, C_MenuClientInit, C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

Private Function cIMenuClient_ProcessMenu(ByVal ID As Long) As Variant
                                                  'Formula de Liquidación
  m_Host.MenuABMClick "CSPersonal.cLiquidacionFormula", Me, LNGGetText(4566, vbNullString), 0, csETablesPersonal.csLiquidacionFormula
  
End Function

' funciones privadas
Private Function LoadCollection() As Boolean
  Dim c As cIABMProperty
  Dim AbmObj  As cABMGeneric
  
  Set AbmObj = m_ObjAbm
  AbmObj.MinWidth = 11000
  AbmObj.MinHeight = 8000
      
  With m_ObjAbm.Tabs
  
    .Clear
      
    With .Add(Nothing)
      .Name = C_strGeneral
    End With
    
    With .Add(Nothing)
      .Index = 1
      .Name = LNGGetText(4567, vbNullString) 'Codigos y Formulas
    End With
    
  End With
  
  m_ObjAbm.Title2 = m_Nombre

  With m_ObjAbm.Properties
    
    .Clear
    
    With .Add(Nothing, cscLiqfNombre)
      .PropertyType = cspText
      .Name = C_strNombre
      .Size = 100
      .Key = K_NOMBRE
      .Value = m_Nombre
      .Width = 6200
    End With
      
    With .Add(Nothing, cscLiqfCodigo)
      .PropertyType = cspText
      .Name = C_strCodigo
      .Size = 15
      .Key = K_CODIGO
      .Value = m_Codigo
    End With
      
    With .Add(Nothing, cscActivo)
      .PropertyType = cspCheck
      .Name = C_strActivo
      .Key = K_ACTIVO
      .Value = CInt(m_Activo)
    End With
      
    With .Add(Nothing)
      .PropertyType = cspLabel
      .Value = LNGGetText(4632, vbNullString)
                        ' No defina variables globales en este codigo. _
                          Este codigo solo debe contener funciones que _
                          se invocaran al ejecutar los codigos de la formula.
      .Width = 5000
      .FontBold = True
      .Height = 800
      .TopToPrevious = 600
    End With
    
    With .Add(Nothing, cscLiqfFormula)
      .PropertyType = cspText
      .Name = LNGGetText(4633, vbNullString) ' Funciones Globales
      .Size = 7000
      .Key = K_FORMULA
      .Value = m_formula
      .SubType = cspMemo
      .Width = 9000
      .Height = 2000
      
    End With
      
    With .Add(Nothing, cscLiqfDescrip)
      .PropertyType = cspText
      .Name = C_strDescrip
      .Size = 255
      .Key = K_DESCRIP
      .Value = m_Descrip
      .SubType = cspMemo
      .Width = 9000
      .Height = 880
    End With
  
    With .Add(Nothing, cscLiqfiDescrip)
      .PropertyType = cspText
      .SubType = cspMemo
      .Enabled = True
      .Value = vbNullString
      .Value = vbNullString
      .Width = 5500
      .Height = 3500
      .Left = 200
      .TabIndex = 1
    End With
  
    With .Add(Nothing, cscLiqfiFormula)
      .PropertyType = cspText
      .SubType = cspMemo
      .Enabled = True
      .Value = vbNullString
      .Left = 5800
      .Width = 5500
      .Height = 3500
      .TabIndex = 1
      .TopFromProperty = cscLiqfiDescrip
    End With
  
    Set c = .Add(Nothing, c_Items)
    With c
      .PropertyType = cspGrid
      .LeftLabel = -1
      If Not pLoadItems(c) Then Exit Function
      .Name = c_Items
      .Key = K_ITEMS
      .TabIndex = 1
      .LeftFromProperty = cscLiqfiDescrip
      .TopFromProperty = cscLiqfiDescrip
      .TopToPrevious = 3600
      .GridAdd = True
      .GridEdit = True
      .GridRemove = True
    
      'Dim o As cABMGrid
      'Set o = c.Grid
      'o.DontResizeHeight = True
    End With
  
    m_ItemsDeletedItems = vbNullString
  
  End With
  
  If Not m_ObjAbm.Show(Me) Then Exit Function
  
  LoadCollection = True
End Function

Private Function Load(ByVal ID As Long) As Boolean

  Dim sqlstmt As String
  Dim rs      As Recordset
  
  sqlstmt = "select * from LiquidacionFormula where liqf_id = " & ID

  If Not gDB.OpenRs(sqlstmt, rs, csRsStatic, csLockReadOnly, csCmdText, C_LoadFunction, C_Module) Then Exit Function

  If Not rs.EOF Then

    m_Id = gDB.ValField(rs.fields, cscLiqfId)
    m_Nombre = gDB.ValField(rs.fields, cscLiqfNombre)
    m_Codigo = gDB.ValField(rs.fields, cscLiqfCodigo)
    m_Descrip = gDB.ValField(rs.fields, cscLiqfDescrip)
    m_formula = gDB.ValField(rs.fields, cscLiqfFormula)
    m_Activo = gDB.ValField(rs.fields, cscActivo)

  Else
    m_Id = csNO_ID
    m_Nombre = vbNullString
    m_Codigo = vbNullString
    m_Descrip = vbNullString
    m_formula = vbNullString
    m_Activo = True

  End If

  Load = True
End Function

Private Sub Class_Initialize()
  On Error GoTo ControlError
  
  c_ErrorSave = LNGGetText(4568, vbNullString) 'Error al grabar la formula de liquidación

  GoTo ExitProc
ControlError:
  MngError Err, "Class_Initialize", C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Sub

' construccion - destruccion
Private Sub Class_Terminate()
  On Error Resume Next
  Set m_ObjAbm = Nothing
  Set m_ObjTree = Nothing
End Sub


'------------------------------------------------------------------
'------------------------------------------------------------------
Private Function cIABMClientGrid_ColumnAfterEdit(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long, ByVal NewValue As Variant, ByVal NewValueID As Long) As Boolean
  cIABMClientGrid_ColumnAfterEdit = True
End Function

Private Function cIABMClientGrid_ColumnBeforeEdit(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long, ByVal iKeyAscii As Integer) As Boolean
  cIABMClientGrid_ColumnBeforeEdit = True
End Function

Private Function cIABMClientGrid_ColumnButtonClick(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long, ByVal iKeyAscii As Integer) As Boolean

End Function

Private Sub cIABMClientGrid_ColumnCancelEdit(ByVal Key As Integer)

End Sub

Private Function cIABMClientGrid_DeleteRow(ByVal Key As Integer, Row As CSInterfacesABM.cIABMGridRow, ByVal lRow As Long) As Boolean
  Dim ID As Long
  
  ID = Val(pCell(Row, KI_LIQFI_ID).Value)
  
  If ID <> csNO_ID Then m_ItemsDeletedItems = m_ItemsDeletedItems & ID & C_StrColon
  
  cIABMClientGrid_DeleteRow = True
End Function

Private Function cIABMClientGrid_ListAdHock(ByVal Key As Integer, Row As CSInterfacesABM.cIABMGridRow, ByVal ColIndex As Long, List As CSInterfacesABM.cIABMList) As Boolean

End Function

Private Sub cIABMClientGrid_NewRow(ByVal Key As Integer, ByVal Rows As Integer)

End Sub

Private Sub cIABMClientGrid_ColumnClick(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long)

End Sub

Private Sub cIABMClientGrid_DblClick(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long)

End Sub

Private Function cIABMClientGrid_ValidateRow(ByVal Key As Integer, Row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  On Error GoTo ControlError

  Select Case Key
    Case K_ITEMS
      cIABMClientGrid_ValidateRow = pValidateRowItems(Row, RowIndex)
  End Select
  
  GoTo ExitProc
ControlError:
  MngError Err, C_ValidateRow, C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

Private Function cIABMClientGrid_ColumnAfterUpdate(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long) As Boolean
  Dim Row As cIABMGridRow
  
  Select Case Key
    Case K_ITEMS
      If pGetItems().Grid.Columns(lCol).Key = KI_CODIGO Then
        Set Row = pGetItems().Grid.Rows.Item(lRow)
        pCell(Row, KI_DESCRIP).Value = pGetLegajo(pCell(Row, KI_CODIGO).ID)
      End If
  End Select
End Function

Private Function cIABMClientGrid_IsEmptyRow(ByVal Key As Integer, Row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  On Error GoTo ControlError

  Select Case Key
    Case K_ITEMS
      cIABMClientGrid_IsEmptyRow = pIsEmptyRowItems(Row, RowIndex)
  End Select
  
  GoTo ExitProc
ControlError:
  MngError Err, C_IsEmptyRow, C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

Private Function pIsEmptyRowItems(ByRef Row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  Dim Cell                  As cIABMGridCellValue
  Dim bRowIsEmpty           As Boolean
  
  bRowIsEmpty = True
  
  For Each Cell In Row
    Select Case Cell.Key
      Case KI_CODIGO
        If Not ValEmpty(Cell.Value, csText) Then
          bRowIsEmpty = False
          Exit For
        End If
      Case KI_NOMBRE
        If Not ValEmpty(Cell.Value, csText) Then
          bRowIsEmpty = False
          Exit For
        End If
    End Select
  Next
  
  pIsEmptyRowItems = bRowIsEmpty
End Function


Private Function pValidateRowItems(Row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  Dim Cell                  As cIABMGridCellValue
  Dim strRow                As String
  
  strRow = " (Fila " & RowIndex & ")"
  
  For Each Cell In Row
    Select Case Cell.Key
        Case KI_NOMBRE
          If ValEmpty(Cell.Value, csText) Then
            MsgInfo C_DebeIndicarNombre
            Exit Function
          End If
        Case KI_CODIGO
          If ValEmpty(Cell.Value, csText) Then
            MsgInfo C_DebeIndicarCodigo
            Exit Function
          End If
        Case KI_LIQCT_ID
          If ValEmpty(Cell.Value, csText) Then
            MsgInfo LNGGetText(1222, vbNullString) ' Debe indicar un tipo
            Exit Function
          End If
    End Select
  Next
  
  pValidateRowItems = True
  
End Function

Private Function pLoadItems(ByRef Propiedad As cIABMProperty) As Boolean
  Dim sqlstmt As String
  Dim rs      As ADODB.Recordset
  
  sqlstmt = "select liqfi.*,liqct_nombre " & _
            " from LiquidacionFormulaItem liqfi " & _
            " inner join LiquidacionCodigoTipo liqct on liqfi.liqct_id = liqct.liqct_id " & _
            " where liqfi.liqf_id = " & m_Id & _
            " order by liqfi_codigo"
  
  If Not gDB.OpenRs(sqlstmt, _
                    rs, _
                    csRsStatic, _
                    csLockReadOnly, _
                    csCmdText, _
                    "pLoadItems", _
                    C_Module) Then Exit Function
  
  With Propiedad.Grid
    
    With .Columns
      
      .Clear
      
      With .Add(Nothing)
        .Visible = False
        .Key = KI_LIQFI_ID
      End With
      
      With .Add(Nothing)
        .Name = C_strNombre
        .PropertyType = cspText
        .Width = 2000
        .Key = KI_NOMBRE
      End With
      
      With .Add(Nothing)
        .Name = C_strCodigo
        .PropertyType = cspText
        .Width = 1000
        .Key = KI_CODIGO
      End With
      
      With .Add(Nothing)
        .Name = C_strDescrip
        .PropertyType = cspText
        .SubType = cspTextButtonEx
        .Width = 2000
        .Key = KI_DESCRIP
      End With
            
      With .Add(Nothing)
        .Name = LNGGetText(4563, vbNullString) 'Nombre Recibo
        .PropertyType = cspText
        .Width = 2000
        .Key = KI_NOMBRERECIBO
      End With
            
      With .Add(Nothing)
        .Name = LNGGetText(1223, vbNullString) 'Tipo
        .PropertyType = cspHelp
        .Table = csLiquidacionCodigoTipo
        .Width = 2000
        .Key = KI_LIQCT_ID
      End With
            
      With .Add(Nothing)
        .Name = LNGGetText(1354, vbNullString) 'Formula
        .PropertyType = cspText
        .SubType = cspTextButtonEx
        .Width = 2000
        .Key = KI_FORMULA
      End With
                        
    End With
    
    With .Rows
      
      .Clear
      
      While Not rs.EOF
      
        With .Add(Nothing, rs(cscLiqfiId).Value)
        
          With .Add(Nothing)
            .Value = rs(cscLiqfiId).Value
            .Key = KI_LIQFI_ID
          End With
          
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscLiqfiNombre)
            .Key = KI_NOMBRE
          End With
                  
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscLiqfiCodigo)
            .Key = KI_CODIGO
          End With
                  
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscLiqfiDescrip)
            .Key = KI_DESCRIP
          End With
                  
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscLiqfiNombrerecibo)
            .Key = KI_NOMBRERECIBO
          End With
                  
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscLiqctNombre)
            .ID = gDB.ValField(rs.fields, cscLiqctId)
            .Key = KI_LIQCT_ID
          End With
                  
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscLiqfiFormula)
            .Key = KI_FORMULA
          End With
                                    
         End With
         
        rs.MoveNext
      Wend
    
    End With
    
  End With
  
  pLoadItems = True

End Function

Private Function pSaveItems() As Boolean
  Dim register As cRegister
  Dim Row  As cIABMGridRow
  Dim Cell As cIABMGridCellValue
  
  With m_ObjAbm.Properties.Item(c_Items).Grid
          
    For Each Row In .Rows
    
      Set register = New cRegister
      With register
        .fieldId = cscLiqfiId
        .Table = csTLiquidacionFormulaItem
        .ID = csNew
        
        For Each Cell In Row
          Select Case Cell.Key
            
            Case KI_LIQFI_ID
              If Not m_Copy Then
                .ID = Val(Cell.Value)
              End If
  
            Case KI_CODIGO
              .fields.Add2 cscLiqfiCodigo, Cell.Value, csText
            Case KI_NOMBRE
              .fields.Add2 cscLiqfiNombre, Cell.Value, csText
          
            Case KI_DESCRIP
              .fields.Add2 cscLiqfiDescrip, Cell.Value, csText
            Case KI_NOMBRERECIBO
              .fields.Add2 cscLiqfiNombrerecibo, Cell.Value, csText
            Case KI_FORMULA
              .fields.Add2 cscLiqfiFormula, Cell.Value, csText
          
            Case KI_LIQCT_ID
              .fields.Add2 cscLiqctId, Cell.ID, csId
          End Select
        Next
        
        .fields.Add2 cscLiqfId, m_Id, csId
        
        .fields.HaveLastUpdate = False
        .fields.HaveWhoModify = False
      End With
      
      If Not gDB.Save(register, , C_pSaveItemsFunc, C_Module, c_ErrorSave) Then Exit Function
    Next
  End With
  
  Dim sqlstmt As String
  
  If LenB(m_ItemsDeletedItems) And Not m_Copy Then
    m_ItemsDeletedItems = RemoveLastColon(m_ItemsDeletedItems)
    sqlstmt = "delete LiquidacionFormulaItem where liqf_id in (" & m_ItemsDeletedItems & ")"
  
    If Not gDB.Execute(sqlstmt, C_pSaveItemsFunc, C_Module) Then Exit Function
  End If
  
  pSaveItems = True
End Function

Private Function pGetItems() As cIABMProperty
  Set pGetItems = m_ObjAbm.Properties.Item(c_Items)
End Function

Private Function pGetLegajo(ByVal em_id As Long) As String
  Dim sqlstmt As String
  Dim rs      As ADODB.Recordset
  
  sqlstmt = "sp_EmpleadoGetLegajo " & em_id
  
  If Not gDB.OpenRs(sqlstmt, rs) Then Exit Function
  If rs.EOF Then Exit Function
  
  pGetLegajo = gDB.ValField(rs.fields, 0)
End Function


