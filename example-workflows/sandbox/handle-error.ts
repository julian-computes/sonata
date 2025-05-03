export const logError = (error: unknown) => {
    if (error instanceof Deno.errors.NotCapable) {
        console.log('The sandbox works as expected.', error.message);
    } else {
        console.error('Encountered unexpected error:', error);
    }
};
