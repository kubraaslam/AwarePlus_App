const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json"); // path to your key

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const COUNSELOR_UID = "5JBRZ1SxjeYDpGxrmJogOQHsISb2";

(async () => {
  try {
    await admin.auth().setCustomUserClaims(COUNSELOR_UID, { counselor: true });
    const user = await admin.auth().getUser(COUNSELOR_UID);
    console.log("Custom claims set:", user.customClaims);
    console.log("Done. Ask the counselor to sign out/in to refresh.");
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
})();
