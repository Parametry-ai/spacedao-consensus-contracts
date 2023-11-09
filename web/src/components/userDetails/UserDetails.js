import {_build_dapp} from "./BuildDapp";

export const UserDetails = ({params}) => {
    let app = _build_dapp(params.dapp1_data.dapp_address, params.dapp1_data.abi)
    let id = app.whatIsMyID();
    return (
        <>
            <div className="account-heading">
                <h3>User: {params.user_address}</h3>
            </div>
            <div className="id-finder">
                <h2>ID: {id}</h2>
            </div>
        </>
    );
}