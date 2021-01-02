import apiMEV-RPC from "../service-descriptions/mev-rpc.json";

import { OpenrpcDocument as OpenRPC } from "@open-rpc/meta-schema";

export interface MEV-RPC {
  [key: string]: OpenRPC;
}

const mevrpc: MEV-RPC = {
  apiMEV-RPC: apiMEV-RPC as OpenRPC,
};

export default mevrpc;