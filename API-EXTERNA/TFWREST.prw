user Function TFwRest()

    Local oSWAPI := FWRest():New("https://swapi.dev/api")
    Local oPokeAPI := FWRest():New("https://pokeapi.co/api/v2")


    oSWAPI:setPath("/people/1/")
    oPokeAPI:setPath("/pokemon/ditto/")

    If oSWAPI:Get()
        ConOut(oSWAPI:GetResult())
    Else
        conout(oSWAPI:GetLastError())
    Endif

    If oPokeAPI:Get()
        ConOut(oPokeAPI:GetResult())
    Else
        conout(oPokeAPI:GetLastError())
    Endif

Return

User function TLeroy

    cURI           := "https://api.leroymerlin.com.br"   // URI DO SERVI�O REST
    oRest     := FwRest():New(cURI)                            // CLIENTE PARA CONSUMO REST

    aHeader   := {}                                            			// CABE�ALHO DA REQUISI��O

// PREENCHE CABE�ALHO DA REQUISI��O
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
    AAdd(aHeader, 'apikey:MIQvDgmCN5mNgWxBQbocDCP7WALeo4OT')

// INFORMA O RECURSO
    cResource := "/v1/orders/purchase/ordersByFiscalID/60837457000187"   // RECURSO A SER CONSUMIDO
    oRest:SetPath(cResource)

    // REALIZA O M�TODO GET E VALIDA O RETORNO
    If oRest:Get(aHeader)
        conOut(oRest:GetResult())
    Else
        conout(oRest:GetLastError())
    Endif




return