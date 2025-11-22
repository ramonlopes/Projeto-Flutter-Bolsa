import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client();

export async function verifyGoogleIdToken(idToken, allowedAudiences) {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: allowedAudiences, // array com seus CLIENT_IDs
  });
  const payload = ticket.getPayload();
  return {
    sub: payload.sub,
    email: payload.email,
    name: payload.name,
    picture: payload.picture,
  };
}