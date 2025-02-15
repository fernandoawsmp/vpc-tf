exports.handler = async (event) => {
    try {
        console.log("Evento recebido:", JSON.stringify(event));

        return {
            statusCode: 200,
            body: JSON.stringify({ mensagem: "Webhook recebido com sucesso!" })
        };
    } catch (error) {
        console.error("Erro na Lambda:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ erro: "Erro interno no servidor" })
        };
    }
};