const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3000;

// MongoDB connection string
const uri = "mongodb+srv://gunplabuilder1608:to06EFGyWbwK84kf@bestlab.gpydqxd.mongodb.net/";

// Create a new MongoClient
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

async function main() {
  try {
    // Connect the client to the server
    await client.connect();
    console.log("Connected successfully to MongoDB");

    // Example: Listing databases
    const databasesList = await client.db().admin().listDatabases();
    console.log("Databases:");
    databasesList.databases.forEach(db => console.log(` - ${db.name}`));

    // Express route example
    app.get('/', (req, res) => {
      res.send('Hello World!');
    });

    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });

  } catch (e) {
    console.error(e);
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}

main().catch(console.error);