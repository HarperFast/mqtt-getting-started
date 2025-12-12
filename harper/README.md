# Harper MQTT Getting Started

A Harper application demonstrating MQTT messaging capabilities.

## Installation

Make sure you have [installed Harper](https://docs.harperdb.io/docs/deployments/install-harper):

```sh
npm install -g harperdb
```

Then install project dependencies:

```sh
npm install
```

## Development

Start your application in development mode:

```sh
npm run dev
```

Or run in production mode:

```sh
npm start
```

## Configuration

- **config.yaml** - Application configuration
- **schema.graphql** - Database schema definition
- **resources.js** - Custom resource classes and application logic

## Code Quality

This project uses [@harperdb/code-guidelines](https://github.com/HarperDB/code-guidelines) for linting, formatting, and TypeScript configuration.

**Format code:**
```sh
npx prettier --write .
```

**Lint code:**
```sh
npx eslint .
```

**Type check:**
```sh
npx tsc
```

## Deployment

Deploy your application to Harper Fabric:

```sh
npm run deploy
```

## Documentation

- [HarperDB Documentation](https://docs.harperdb.io/docs)
- [Components Reference](https://docs.harperdb.io/docs/reference/components)
- [Getting Started Guide](https://docs.harperdb.io/docs)

## License

Apache 2.0
