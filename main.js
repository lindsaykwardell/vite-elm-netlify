import "./style.css";
import { Elm } from "./src/Main.elm";
import netlifyIdentity, { currentUser } from "netlify-identity-widget";

const root = document.querySelector("#app div");
const app = Elm.Main.init({
  node: root,
  flags: {
    currentUser:
      (netlifyIdentity.currentUser() && {
        name: netlifyIdentity.currentUser()?.user_metadata.full_name,
      }) ||
      null,
  },
});

netlifyIdentity.init();

function getCurrentUser() {
  return {
    name: netlifyIdentity.currentUser()?.user_metadata.full_name,
  };
}

if (netlifyIdentity.currentUser()) {
  app.ports.receiveUser.send(getCurrentUser());
}

netlifyIdentity.on("login", () => {
  app.ports.receiveUser.send(getCurrentUser());
  netlifyIdentity.close()
});

app.ports.openLogin.subscribe(() => {
  netlifyIdentity.open("login");
});

app.ports.logout.subscribe(() => {
  netlifyIdentity.logout();
});
