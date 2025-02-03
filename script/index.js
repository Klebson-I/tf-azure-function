module.exports = async function (context, request) {
    context.log('Http function was triggered.');
    context.res = { body: 'Hello, world!' };
};