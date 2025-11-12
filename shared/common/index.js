import pino from 'pino';
export const logger = pino({
    level: 'info',
    formatters: {
        level: (label) => {
            return { level: label };
        },
    },
    timestamp: pino.stdTimeFunctions.isoTime,
    msgPrefix: '', // Add msgPrefix for Fastify compatibility
});
//# sourceMappingURL=index.js.map