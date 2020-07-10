#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL MeuRest DESCRIPTION "Exemplo de Rest Manual"

    WSDATA id  AS STRING OPTIONAL

    WSMETHOD GET         DESCRIPTION "Retorna todos os clientes"  WSSYNTAX "MEUREST/"       PATH "/MEUREST"      
    WSMETHOD GET GetById DESCRIPTION "Retorna um cliente"         WSSYNTAX "MEUREST/{id}"   PATH "/MEUREST/{id}" 
    WSMETHOD PUT         DESCRIPTION "Atualiza um cliente"        WSSYNTAX "MEUREST/{id}"   PATH "/MEUREST/{id}" 
    WSMETHOD POST        DESCRIPTION "Cria um cliente"            WSSYNTAX "MEUREST"        PATH "/MEUREST"      
    WSMETHOD DELETE      DESCRIPTION "Exclui um cliente"          WSSYNTAX "MEUREST/{id}"   PATH "/MEUREST/{id}" 

END WSRESTFUL

/** Retorna todos os clientes
 */
WSMETHOD GET WSSERVICE MeuRest
    Local lPost     := .T.
    Local oResponse := JsonObject():New()
    Local aTarefas  := {}
    Local aTasks    := {}
    Local cJson     := ""

    ::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery := " SELECT "
    cQuery += "    SA1.A1_COD, "
    cQuery += "    SA1.A1_NOME "
    cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
    cQuery += " WHERE "
    cQuery += "        SA1.A1_FILIAL   = '" + xFilial("SA1") + "' "
    cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)

    If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())
            oTask := JsonObject():New()
            oTask['code'] := (cAlias)->A1_COD
            oTask['description'] := (cAlias)->A1_NOME
            AAdd(aTasks, oTask)

            (cAlias)->(DbSkip())

        End
        cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
        ::SetResponse(cResponse)

    Else
        cResponse := FWJsonSerialize(aTasks, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

    (cAlias)->(DbCloseArea())
Return lPost

/** Retorna cliente passado por parametro
 */
WSMETHOD GET GetById PATHPARAM id WSSERVICE MeuRest
    Local lPost    := .T.
    Local oResponse := JsonObject():New()

    Local aTarefas := {}

    ::SetContentType("application/json")

    cAlias := GetNextAlias()
    cQuery := " SELECT "
    cQuery += "    SA1.A1_COD, "
    cQuery += "    SA1.A1_NOME "
    cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
    cQuery += " WHERE "
    cQuery += "        SA1.A1_FILIAL   = '" + xFilial("SA1") + "' "
    cQuery += "    AND SA1.A1_COD = '" + ::id + "'
    cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)

    If (cAlias)->(!Eof())
        lPost := .T.
        oResponse['code'] := (cAlias)->A1_COD
        oResponse['description'] := (cAlias)->A1_NOME

        cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
        ::SetResponse(cResponse)
    Else
        lPost := .F.
        cRetorno := "Cliente não encontrado!"
        SetRestFault(404, cRetorno)
    EndIf

    (cAlias)->(DbCloseArea())
Return lPost

/** Altera um cliente
 */
WSMETHOD PUT PATHPARAM id WSREST MeuRest
    Local cCliente   := PadL(Upper(AllTrim(::id)),6,"0")
    Local oResponse := JsonObject():New()
    Local oModel    := FwLoadModel("MATA030")
    Local oRequest  := JsonObject():New()

    ::SetContentType("application/json")

    If SA1->(DbSeek(XFilial("SA1") + cCliente))

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()
        oRequest:fromJson(::GetContent())

        oModel:GetModel('MATA030_SA1'):SetValue("A1_NOME", oRequest["nome"])

        If (oModel:VldData() .and. oModel:CommitData())
            lPost := .T.
            oResponse['sucess'] := .T.
            cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
            ::SetResponse(cResponse)
        Else
            lPost := .F.
            aError := oModel:GetErrorMessage()
            cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
            SetRestFault(400, cRetorno)
        EndIf

        oModel:DeActivate()
    Else
        SetRestFault(400, "Cliente nï¿½o localizado")
    EndIf

Return lPost

/** Cria um cliente
 */
WSMETHOD POST WSREST MeuRest

    Local cCliente   := PadL(Upper(AllTrim(::id)),6,"0")
    Local oResponse := JsonObject():New()
    Local oModel    := FwLoadModel("MATA030")// MVC
    Local oRequest  := JsonObject():New()

    ::SetContentType("application/json")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    oRequest:fromJson(::GetContent())

    oModel:GetModel('MATA030_SA1'):SetValue("A1_COD"    , oRequest["codigo"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_LOJA"   , oRequest["loja"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_NOME"   , oRequest["nome"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_NREDUZ" , oRequest["fantasia"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_END"    , oRequest["endereco"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_TIPO"   , oRequest["tipo"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_EST"    , oRequest["estado"])
    oModel:GetModel('MATA030_SA1'):SetValue("A1_MUN"    , oRequest["municipio"])

    If (oModel:VldData() .and. oModel:CommitData())
        lPost := .T.
        ::SetResponse(oModel:GetJsonData())
    Else
        lPost := .F.
        aError := oModel:GetErrorMessage()
        cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
        SetRestFault(400, cRetorno)
    EndIf

    oModel:DeActivate()

Return lPost

/** Deleta um cliente
 */
WSMETHOD DELETE PATHPARAM id WSREST MeuRest

    Local cCliente   := PadL(Upper(AllTrim(::id)),6,"0")
    Local oResponse := JsonObject():New()
    Local oModel    := FwLoadModel("MATA030")

    ::SetContentType("application/json")

    If SA1->(DbSeek(XFilial("SA1") + cCliente))

        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()

        If (oModel:VldData() .and. oModel:CommitData())
            lPost := .T.
            oResponse['sucess'] := .T.
            cResponse := FWJsonSerialize(oResponse, .F., .F., .T.)
            ::SetResponse(cResponse)
        Else
            lPost := .F.
            aError := oModel:GetErrorMessage()
            cRetorno := "ERRO|" + aError[5] + " | " + aError[6] + " | " + aError[7]
            SetRestFault(400, cRetorno)
        EndIf

        oModel:DeActivate()
    Else
        SetRestFault(400, "Cliente nï¿½o localizado")
    EndIf

Return lPost



