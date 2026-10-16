import { handleVideoRequest } from "../_shared/video.ts";
Deno.serve((request) => handleVideoRequest(request, "playback"));
