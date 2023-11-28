import "./HeroImgStyles.css";
import { React } from "react";

// import HomeImg from "../../assets/home-img.jpg";
//import { Link } from "react-router-dom";

export const HeroImg = () => {
  return (
    <div className="hero">
      <img className="intro-img" src={"https://static.scientificamerican.com/sciam/cache/file/41DF7DA0-EE58-4259-AA815A390FB37C55_source.jpg?w=590&h=800&92AD8A57-5046-4AC2-B2480CC9628B1F2E"} alt='Hero' />

      <div className="content">
       <h1>SpaceDAO STM Consensus Hub</h1>
        <p>Consensus across Collision Detection Messages in Satellite Traffic Management</p>  
        {/* <div>
          <Link to="/project" className="btn btn-light">
            Social Activation
          </Link>
          <Link to="/contact" className="btn btn-light">
            Automatic Tasking
          </Link>
          <Link to="/contact" className="btn btn-light">
            Data Consensus
          </Link>
        </div> */}
      </div>
    </div>
  );
};

