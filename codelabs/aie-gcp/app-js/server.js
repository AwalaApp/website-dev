import { PubSub } from '@google-cloud/pubsub';
import envVar from 'env-var';
import Fastify from 'fastify';

const OUTGOING_MESSAGES_TOPIC = envVar.get('OUTGOING_MESSAGES_TOPIC')
    .required().asString();

const pubSubClient = new PubSub();

const fastify = Fastify({ logger: true });

fastify.get('/', async (_request, reply) => {
    // Used by the health check
    return reply.send('All good!');
});

fastify.post('/', async (request, reply) => {
    // Extract the message and its metadata
    const pingData = request.body.message.data;
    const pingMessageAttributes = request.body.message.attributes;
    const pingSenderId = pingMessageAttributes.source;
    const pingRecipientId = pingMessageAttributes.subject;

    // Send the pong message
    const pongEvent = {
        data: pingData,
        attributes: {
            source: pingRecipientId,
            subject: pingSenderId,
        },
    };
    const topic = pubSubClient.topic(OUTGOING_MESSAGES_TOPIC);
    await topic.publishMessage(pongEvent);

    return reply.send('Message processed');
});

const start = async () => {
    try {
        await fastify.listen({ port: 8080, host: '0.0.0.0' });
    } catch (err) {
        fastify.log.error(err);
        process.exit(1);
    }
}
start();

