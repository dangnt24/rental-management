import { createRoot } from "react-dom/client";
import { App } from "./app/App";
import "./styles.css";
import { InteractionGuard } from "./shared/InteractionGuard";

createRoot(document.getElementById("root")!).render(
  <InteractionGuard>
    <App />
  </InteractionGuard>,
);
