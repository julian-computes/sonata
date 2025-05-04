// Parse command line arguments into a map
const args = Deno.args.reduce((map, arg, index, array) => {
  if (arg.startsWith("--") && index + 1 < array.length) {
    map.set(arg, array[index + 1]);
  }
  return map;
}, new Map<string, string>());

const workflowPath = Deno.args[0]; // First arg is always the workflow path
const outputPath = args.get("--output")!;

const main = async () => {
  if (!workflowPath) {
    throw new Error("No workflow file specified");
  }

  // Import the workflow module in a sandboxed context
  const workflow = await import(workflowPath);

  // Check if it has a main function
  if (typeof workflow.main !== "function") {
    throw new Error("Workflow must export a 'main' function");
  }

  // Execute the main function in the sandboxed context
  return workflow.main();
};

try {
  const result = await main();
  await Deno.writeTextFile(
    outputPath,
    JSON.stringify({
      status: "success",
      result,
    }),
  );
} catch (error) {
  await Deno.writeTextFile(
    outputPath,
    JSON.stringify({
      status: "error",
      error,
    }),
  );
}
