let secrets = {};

try {
  secrets = JSON.parse(open('./.secrets.json'));
} catch (err) {}

export default secrets;
