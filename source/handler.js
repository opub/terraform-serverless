'use strict';

// Simple Node.js Lambda function to query list of tables from PostgreSQL database

const pg = require('pg')
const aws = require('aws-sdk')
const ssm = new aws.SSM()

// database connection pool
const pool = new pg.Pool({
  host: process.env.DATABASE_ENDPOINT,
  port: process.env.DATABASE_PORT,
  database: process.env.DATABASE_NAME,
  user: process.env.DATABASE_USER,
  password: null,
  max: 20,
  idleTimeoutMillis: 120000,
  connectionTimeoutMillis: 10000,
})

// SSM password params
const ssmpass = {
  Name: '/' + process.env.APPLICATION_ENV + '/database/password',
  WithDecryption: true
}

// get password value from SSM
async function getPassword() {
  try {
    let resp = await ssm.getParameter(ssmpass).promise()
    return resp.Parameter.Value;
  } catch (err) {
    console.log('ERROR: getPassword - ' + err)
    throw err;
  }
}

// execute database query
async function query (q) {
  // retrieve password if needed
  if (!pool.options.password) {
    let pwd = await getPassword()
    pool.options.password = pwd
  }

  // query in transaction with commit or rollback
  let client = await pool.connect()
  let res
  try {
    await client.query('BEGIN')
    try {
      res = await client.query(q)
      await client.query('COMMIT')
    } catch (err) {
      await client.query('ROLLBACK')
      console.log('ERROR: query - ' + err)
      throw err
    }
  } finally {
    client.release()
  }
  return res
}

// hello world equivalent in PostgreSQL 
module.exports.hellodb = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false; // important for pool reuse

  try {
    let { rows } = await query("select * from pg_tables")
    // console.log('sample result: ' + JSON.stringify(rows[0]))
    return {
      statusCode: 200,
      body: JSON.stringify(rows),
    };
  } catch (err) {
    console.log('ERROR: ' + err)
    return {
      statusCode: 500,
      body: err,
    };
  }
};
