const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");

const client = new SQSClient({ region: "us-east-1" });
const SQS_URL = "https://sqs.us-east-1.amazonaws.com/975050217683/n8n";

exports.handler = async (event) => {
    try {
        console.log("Evento recebido:", JSON.stringify(event));

        const params = {
            QueueUrl: SQS_URL,
            MessageBody: JSON.stringify(event)
        };

        await client.send(new SendMessageCommand(params));

        return {
            statusCode: 200,
            body: JSON.stringify({ mensagem: "Webhook recebido e enviado ao SQS com sucesso!" })
        };
    } catch (error) {
        console.error("Erro na Lambda:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ erro: "Erro interno no servidor" })
        };
    }
};
