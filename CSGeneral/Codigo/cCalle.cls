VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cCalle"
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
' cCalle
' 30-01-01

'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
' api win32
    ' constantes
    ' estructuras
    ' funciones

'--------------------------------------------------------------------------------

' constantes
Private Const C_Module = "cCalle"

Private Const c_alturas    As String = "alturas"

Private Const K_NOMBRE       As Integer = 1
Private Const K_CODIGO       As Integer = 2
Private Const K_ACTIVO       As Integer = 3
Private Const K_DESCRIP      As Integer = 4
Private Const K_CIUDAD       As Integer = 5
Private Const K_ALTURAS      As Integer = 11

Private Const KI_CALLEA_ID                    As Integer = 1
Private Const KI_DESDE                        As Integer = 6
Private Const KI_HASTA                        As Integer = 7

' pseudo-constantes
Private c_ErrorSave As String

' estructuras
' variables privadas
Private m_Id                 As Long
Private m_Nombre             As String
Private m_Codigo             As String
Private m_Activo             As Boolean
Private m_Ciudad             As String
Private m_ciu_id             As Long
Private m_descrip            As String

Private m_Editing            As Boolean

Private m_ItemsDeleted       As String

Private m_ObjAbm             As cIABMGeneric
Private m_ObjTree            As Object

Private m_IsNew              As Boolean

Private m_BranchId           As Long
Private m_TreeId             As Long

Private m_Host               As CSMenu.cIMenuHost
Private m_Copy               As Boolean

Private m_WasChanged         As Boolean

' propiedades publicas

Public Property Get Id() As Long
  Id = m_Id
End Property

Public Property Get Nombre() As String
  Nombre = m_Nombre
End Property

Public Property Get Codigo() As String
  Codigo = m_Codigo
End Property
' propiedades privadas
' funciones publicas

' Implementacion de cIABMClient
Private Function cIABMClient_Copy() As Boolean
  
  cIABMClient_Terminate
  m_IsNew = True
  
  With m_ObjAbm.Properties(cscCalleCodigo)
    .Value = C_C & .Value
  End With
  
'  With m_ObjAbm.Properties(cscCalleNombre)
'    .Value = C_CopiaDe & .Value
'  End With
  
  m_ObjAbm.ShowValue m_ObjAbm.Properties(cscCalleCodigo)
  m_ObjAbm.ShowValue m_ObjAbm.Properties(cscCalleNombre)
  
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

  Doc.ClientTable = csTCalle
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
                               csPreGNewCalle
      cIABMClient_MessageEx = MSG_DOC_INFO_HANDLED
    Case Else
      cIABMClient_MessageEx = True
  End Select
End Function

Private Sub cIABMClient_DiscardChanges()
    LoadCollection
End Sub

Private Function cIABMClient_ListAdHock(Lista As CSInterfacesABM.cIABMList) As Boolean

End Function

Private Sub cIABMClient_Load()

End Sub

Private Function cIABMClient_PropertyChange(ByVal Key As Integer) As Boolean

End Function

Private Function cIABMClient_Save() As Boolean
  Dim LastId     As Long
  Dim register   As cRegister
  Dim fields     As cFields
  
  Set register = New cRegister
  Set fields = register.fields
  
  With register
    .fieldId = cscCalleId
    .Table = csTCalle
    
    If m_Copy Then
      .Id = csNew
    Else
      .Id = m_Id
    End If
  End With
  
  Dim IProperty As cIABMProperty
  For Each IProperty In m_ObjAbm.Properties
    With IProperty
      Select Case .Key
        Case K_NOMBRE
            fields.Add2 cscCalleNombre, .Value, csText
        Case K_CODIGO
            fields.Add2 cscCalleCodigo, .Value, csText
        Case K_ACTIVO
            fields.Add2 cscActivo, Val(.Value), csBoolean
        Case K_CIUDAD
            fields.Add2 cscCiuId, Val(.HelpId), csId
        Case K_DESCRIP
            fields.Add2 cscCalleDescrip, .Value, csText
      End Select
    End With
  Next
    
  fields.HaveLastUpdate = True
  fields.HaveWhoModify = True
    
  If Not register.BeginTrans(gDB) Then Exit Function
  
  If Not gDB.SaveEx(register, , _
                    cscCalleCodigo, _
                    C_ABMClientSave, _
                    C_Module, _
                    c_ErrorSave) Then Exit Function
  
  LastId = m_Id
  m_Id = register.Id
  
  If Not pSaveAlturas() Then GoTo SaveError
  
  If Not register.CommitTrans() Then GoTo SaveError
  
  m_Copy = False
  cIABMClient_Save = Load(register.Id)
  
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
    cIABMClient_Title = LNGGetText(3921, vbNullString) 'Calles
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
        Case K_CIUDAD
          If ValEmpty(Val(.HelpId), csId) Then
              MsgInfo LNGGetText(3922, vbNullString) 'Debe indicar una ciudad
              Exit Function
          End If
              
      End Select
    End With
  Next
  
  cIABMClient_Validate = True
End Function

Private Function cIABMClientGrid_ColumnAfterEdit(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long, ByVal NewValue As Variant, ByVal NewValueID As Long) As Boolean
  cIABMClientGrid_ColumnAfterEdit = True
End Function

Private Function cIABMClientGrid_ColumnAfterUpdate(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long) As Boolean
  Select Case Key
    Case K_ALTURAS
      m_WasChanged = True
  End Select
  cIABMClientGrid_ColumnAfterUpdate = True
End Function

Private Function cIABMClientGrid_ColumnBeforeEdit(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long, ByVal iKeyAscii As Integer) As Boolean
  cIABMClientGrid_ColumnBeforeEdit = True
End Function

Private Function cIABMClientGrid_ColumnButtonClick(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long, ByVal iKeyAscii As Integer) As Boolean

End Function

Private Sub cIABMClientGrid_ColumnCancelEdit(ByVal Key As Integer)

End Sub

Private Sub cIABMClientGrid_ColumnClick(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long)

End Sub

Private Sub cIABMClientGrid_DblClick(ByVal Key As Integer, ByVal lRow As Long, ByVal lCol As Long)

End Sub

Private Function cIABMClientGrid_DeleteRow(ByVal Key As Integer, row As CSInterfacesABM.cIABMGridRow, ByVal lRow As Long) As Boolean
  Dim Id As Long
  
  Select Case Key
    Case K_ALTURAS
      Id = Val(pCell(row, KI_CALLEA_ID).Value)
      If Id <> csNO_ID Then m_ItemsDeleted = m_ItemsDeleted & Id & C_StrColon
  End Select
  
  cIABMClientGrid_DeleteRow = True
End Function

Private Function cIABMClientGrid_IsEmptyRow(ByVal Key As Integer, row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  On Error GoTo ControlError

  Select Case Key
    Case K_ALTURAS
      cIABMClientGrid_IsEmptyRow = pIsEmptyRow(row, RowIndex)
  End Select
  
  GoTo ExitProc
ControlError:
  MngError Err, C_ValidateRow, C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

Private Function cIABMClientGrid_ListAdHock(ByVal Key As Integer, row As CSInterfacesABM.cIABMGridRow, ByVal ColIndex As Long, List As CSInterfacesABM.cIABMList) As Boolean

End Function

Private Sub cIABMClientGrid_NewRow(ByVal Key As Integer, ByVal Rows As Integer)

End Sub

Private Function cIABMClientGrid_ValidateRow(ByVal Key As Integer, row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  On Error GoTo ControlError

  Select Case Key
    Case K_ALTURAS
      cIABMClientGrid_ValidateRow = pValidadeRow(row, RowIndex)
  End Select
  
  GoTo ExitProc
ControlError:
  MngError Err, C_ValidateRow, C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

' Implementacion de cIEditGeneric
Private Property Get cIEditGeneric_ObjAbm() As CSInterfacesABM.cIABMGeneric
  Set cIEditGeneric_ObjAbm = m_ObjAbm
End Property

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
    cIEditGeneric_ShowList = SecurityCanAccess(csPreGListCalle)
End Function

Private Property Set cIEditGeneric_ObjAbm(rhs As CSInterfacesABM.cIABMGeneric)
    Set m_ObjAbm = rhs
End Property

Private Property Get cIEditGeneric_Editing() As Boolean
    cIEditGeneric_Editing = m_Editing
End Property

Private Function cIEditGeneric_Delete(Id As Long) As Boolean
    If Not SecurityCanAccess(csPreGDeleteCalle) Then Exit Function

    Dim sqlstmt As String
    
    sqlstmt = "delete CalleAltura where calle_Id = " & Id & _
              " delete Calle where calle_Id = " & Id
    
    cIEditGeneric_Delete = gDB.Execute(sqlstmt, C_EditGenericDelete, C_Module)
End Function

Private Function cIEditGeneric_Search(Id As Long, Cancela As Boolean) As Boolean

End Function

Private Function cIEditGeneric_Edit(Id As Long, Optional ByVal InModalWindow As Boolean) As Boolean
  On Error GoTo ControlError
  
  If Id = csNO_ID Then
    m_IsNew = True
    If Not SecurityCanAccess(csPreGNewCalle) Then Exit Function
  Else
    m_IsNew = False
    If Not SecurityCanAccess(csPreGEditCalle) Then Exit Function
  End If

  m_ObjAbm.InModalWindow = InModalWindow

  If Not Load(Id) Then Exit Function
  
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

Private Function cIEditGeneric_PrintObj(ByVal Id As Long) As Boolean

End Function

Private Property Set cIEditGeneric_ObjTree(rhs As Object)
    Set m_ObjTree = rhs
End Property

Private Function cIEditGeneric_PropertyChange(ByVal Key As Integer) As Boolean

End Function

Private Property Let cIEditGeneric_BranchId(ByVal rhs As Long)
    m_BranchId = rhs
End Property

Private Property Get cIEditGeneric_BranchId() As Long
    cIEditGeneric_BranchId = m_BranchId
End Property

Private Function cIEditGeneric_TabClick(ByVal Index As Integer) As Boolean

End Function

Private Function cIEditGeneric_Preview(ByVal Id As Long) As Boolean

End Function

Private Function cIMenuClient_Initialize(F As Object, Host As CSMenu.cIMenuHost) As Boolean
  On Error GoTo ControlError
  
  Set m_Host = Host
  
  m_Host.Server.AddMenu C_MenuGeneral, csMenuConfigGeneral, C_MenuConfig, 0, True, False, False, False, True, Nothing
                        '&Calles
  m_Host.Server.AddMenu LNGGetText(3923, vbNullString), csPreGListCalle, C_MenuGeneral, 0, True, False, False, False, False, Me
  
  cIMenuClient_Initialize = True

  GoTo ExitProc
ControlError:
  MngError Err, C_MenuClientInit, C_Module, vbNullString
  If Err.Number Then Resume ExitProc

ExitProc:
  On Error Resume Next
End Function

Private Function cIMenuClient_ProcessMenu(ByVal Id As Long) As Variant
                                                          'Calle
  m_Host.MenuABMClick "CSGeneral2.cCalle", Me, LNGGetText(1194, vbNullString), 0, csETablasGeneral.csCalle
End Function

' funciones privadas
Private Function LoadCollection() As Boolean
  Dim c As cIABMProperty
  Dim iProp As cABMProperty
  
  m_ObjAbm.Title2 = m_Nombre
  
  Const tab_general = 0
  
  With m_ObjAbm.Tabs
    
    .Clear
  
    With .Add(Nothing)
      .Name = C_strGeneral
    End With
      
    With .Add(Nothing)
      .Index = 1
      .Name = LNGGetText(3924, vbNullString)  'Alturas
    End With
  End With
  
  With m_ObjAbm.Properties
    
    .Clear

    With .Add(Nothing, cscCalleNombre)
      .PropertyType = cspText
      .Name = C_strNombre
      .Size = 100
      .Width = 7450
      .Key = K_NOMBRE
      .Value = m_Nombre
    End With
    
    With .Add(Nothing, cscCalleCodigo)
      .PropertyType = cspText
      .Name = C_strCodigo
      .Size = 15
      .Value = m_Codigo
      .Key = K_CODIGO
    End With
    
    With .Add(Nothing, cscActivo)
      .TopFromProperty = cscCalleCodigo
      .Left = 5000
      .LeftLabel = -600
      .LeftNotChange = True
      .PropertyType = cspCheck
      .Name = C_strActivo
      .Key = K_ACTIVO
      .Value = CInt(m_Activo)
    End With
        
    With .Add(Nothing, cscCiuId)
      .PropertyType = cspHelp
      .Table = csCiudad
      .Name = LNGGetText(1079, vbNullString)    'Ciudad
      .Key = K_CIUDAD
      .Value = m_Ciudad
      .Width = 3000
      .HelpId = m_ciu_id
    End With
                
    With .Add(Nothing, cscCalleDescrip)
      .PropertyType = cspText
      .Name = C_strDescrip
      .LeftFromProperty = cscCalleNombre
      .TopFromProperty = cscCiuId
      .TopToPrevious = 440
      .Height = 660
      .Width = 7450
      .Size = 255
      .SubType = cspMemo
      .Key = K_DESCRIP
      .Value = m_descrip
    End With
        
    Set c = .Add(Nothing, c_alturas)
    With c
      .PropertyType = cspGrid
      .LeftLabel = -1
      If Not pLoadAlturas(c) Then Exit Function
      .Name = LNGGetText(3924, vbNullString)   'Alturas
      .Key = K_ALTURAS
      .GridAdd = True
      .GridEdit = True
      .GridRemove = True
      .TabIndex = 1
    End With

    m_ItemsDeleted = vbNullString

  End With
      
  If Not m_ObjAbm.Show(Me) Then Exit Function

  LoadCollection = True
End Function

Private Function Load(ByVal Id As Long) As Boolean
  
  Dim sqlstmt As String
  Dim rs      As ADODB.Recordset
  
  sqlstmt = "select c.*,ciu_nombre from calle c inner join ciudad ciu on c.ciu_id = ciu.ciu_id and calle_id = " & Id
  
  If Not gDB.OpenRs(sqlstmt, rs, csRsStatic, csLockReadOnly, csCmdText, C_LoadFunction, C_Module) Then Exit Function
  
  If rs.EOF Then
    m_Activo = True
    m_Nombre = vbNullString
    m_Codigo = vbNullString
    m_descrip = vbNullString
    m_Id = csNO_ID
    m_ciu_id = csNO_ID
    m_Ciudad = vbNullString
  Else
    m_Activo = gDB.ValField(rs.fields, cscActivo)
    m_Nombre = gDB.ValField(rs.fields, cscCalleNombre)
    m_Codigo = gDB.ValField(rs.fields, cscCalleCodigo)
    m_descrip = gDB.ValField(rs.fields, cscCalleDescrip)
    m_Id = gDB.ValField(rs.fields, cscCalleId)
    m_ciu_id = gDB.ValField(rs.fields, cscCiuId)
    m_Ciudad = gDB.ValField(rs.fields, cscCiuNombre)
  End If
  Load = True
End Function

Private Function pLoadAlturas(ByRef Propiedad As cIABMProperty) As Boolean
  
  Dim sqlstmt As String
  Dim rs      As ADODB.Recordset
  
  m_WasChanged = False

  Dim filter As String
  
  sqlstmt = "select * from CalleAltura where calle_id = " & m_Id
    
  If Not gDB.OpenRs(sqlstmt, _
                    rs, _
                    csRsStatic, _
                    csLockReadOnly, _
                    csCmdText, _
                    C_LoadFunction, _
                    C_Module) Then Exit Function
  
  With Propiedad.Grid
    With .Columns
    
      .Clear
      
      With .Add(Nothing)
        .Visible = False
        .Key = KI_CALLEA_ID
      End With
    
      With .Add(Nothing)
        .Name = LNGGetText(2532, vbNullString)  'Desde
        .PropertyType = cspNumeric
        .SubType = cspDouble
        .Format = "0"
        .Width = 1200
        .Key = KI_DESDE
      End With
    
      With .Add(Nothing)
        .Name = LNGGetText(2533, vbNullString)  'Hasta
        .PropertyType = cspNumeric
        .SubType = cspDouble
        .Format = "0"
        .Width = 1200
        .Key = KI_HASTA
      End With
    
    End With
          
    With .Rows
    
      .Clear
    
      While Not rs.EOF
      
        With .Add(Nothing, rs(cscCalleaId).Value)
          
          With .Add(Nothing)
            .Value = rs(cscCalleaId).Value
            .Key = KI_CALLEA_ID
          End With
          
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscCalleaDesde)
            .Key = KI_DESDE
          End With
          With .Add(Nothing)
            .Value = gDB.ValField(rs.fields, cscCalleaHasta)
            .Key = KI_HASTA
          End With
       
        End With
                
        rs.MoveNext
      Wend
    
    End With
  End With
  
  pLoadAlturas = True

End Function

Private Function pSaveAlturas() As Boolean
  
  Dim register  As cRegister
  Dim fields    As cFields
  Dim IProperty As cIABMProperty
  
  With m_ObjAbm.Properties.Item(c_alturas)
    Dim row  As cIABMGridRow
    Dim Cell As cIABMGridCellValue
    
    For Each row In .Grid.Rows
    
      Set register = New cRegister
      
      With register
        Set fields = .fields
        .fieldId = cscCalleaId
        .Table = csTCalleAltura
        .Id = csNew
        
        For Each Cell In row
          Select Case Cell.Key
            
            Case KI_CALLEA_ID
              If Not m_Copy Then
                .Id = Val(Cell.Value)
              End If
            
            Case KI_DESDE
              fields.Add2 cscCalleaDesde, Cell.Value, csDouble
            Case KI_HASTA
              fields.Add2 cscCalleaHasta, Cell.Value, csDouble
          
          End Select
        Next
        
        fields.Add2 cscCalleId, m_Id, csId
        
        fields.HaveLastUpdate = False
        fields.HaveWhoModify = False
        
      End With
                                                              
      If Not gDB.Save(register, , "pSaveAlturas", C_Module, c_ErrorSave) Then Exit Function
    Next
  End With
  
  Dim sqlstmt As String
  
  If m_ItemsDeleted <> vbNullString And Not m_Copy Then
    m_ItemsDeleted = RemoveLastColon(m_ItemsDeleted)
    sqlstmt = "delete CalleAltura where callea_id in (" & m_ItemsDeleted & ")"
  
    If Not gDB.Execute(sqlstmt, "pSaveAlturas", C_Module) Then Exit Function
  End If
  
  pSaveAlturas = True
End Function

Private Function pValidadeRow(row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  Dim Cell                  As cIABMGridCellValue
  Dim strRow                As String
  
  strRow = " (Fila " & RowIndex & ")"
  
  For Each Cell In row
    Select Case Cell.Key
      Case KI_DESDE
        If Val(Cell.Value) < 0 Then
                    'Debe indicar una altura inicial
          MsgInfo LNGGetText(3925, vbNullString, strRow)
          Exit Function
        End If
      Case KI_HASTA
        If Val(Cell.Value) <= 0 Then
                    'Debe indicar una altura final
          MsgInfo LNGGetText(3926, vbNullString, strRow)
          Exit Function
        End If
    End Select
  Next
  
  pValidadeRow = True
End Function

Private Function pIsEmptyRow(ByRef row As CSInterfacesABM.cIABMGridRow, ByVal RowIndex As Long) As Boolean
  Dim Cell                  As cIABMGridCellValue
  Dim bRowIsEmpty           As Boolean
  
  bRowIsEmpty = True
  
  For Each Cell In row
    Select Case Cell.Key
      Case KI_DESDE, KI_HASTA
        If Val(Cell.Value) > 0 Then
          bRowIsEmpty = False
          Exit For
        End If
    End Select
  Next
  
  pIsEmptyRow = bRowIsEmpty
End Function

' construccion - destruccion
Private Sub Class_Initialize()
  On Error Resume Next
  c_ErrorSave = LNGGetText(3927, vbNullString) 'Error al grabar la calle
End Sub

Private Sub Class_Terminate()
  On Error Resume Next
  Set m_ObjAbm = Nothing
  Set m_ObjTree = Nothing
End Sub
