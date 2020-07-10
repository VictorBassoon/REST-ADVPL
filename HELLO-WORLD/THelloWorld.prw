#include "protheus.ch"
#include "restful.ch"

WSRESTFUL helloworld DESCRIPTION "Meu Primeiro serviço REST!"
    WSMETHOD GET DESCRIPTION "Retornar um Hello World" WSSYNTAX "/helloworld" PATH "/helloworld"
END WSRESTFUL


WSMETHOD GET WSSERVICE helloworld
//Esse cara indica que vamos retornar um HTML, apenas para o nosso primeiro retorno
    ::SetContentType("application/json")
    ::setResponse('[{"Status":"Hello World"}]')
    ::setStatus(200)

return .T.




    