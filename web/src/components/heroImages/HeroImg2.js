import "./HeroImg2Styles.css";
//import React, { Component } from "react";

// import Image_of_the_back from "../../assets/social-activation-img.jpg";

// export class HeroImg2 extends Component {
//   render() {
//       return (
//         <div className="hero">
//           <div className="mask">
//             <img className="hero-img" src={Image_of_the_back} alt='Background Img' />
//           </div>

//           <div className="heading">
//             <h1>{this.props.heading}</h1>
//             <p> {this.props.text} </p>
//           </div>
//         </div>
//          );
//   }
// };

export const HeroImg2 = ({heading, text}) => {
  return (
    <div>
      <div className="hero-img">
        <img src={"https://static.scientificamerican.com/sciam/cache/file/41DF7DA0-EE58-4259-AA815A390FB37C55_source.jpg?w=590&h=800&92AD8A57-5046-4AC2-B2480CC9628B1F2E"} alt='Background' />
      </div>
      <div className="hero-heading">
        <h1>{heading}</h1>
        <p> {text} </p>
      </div>
    </div>
    // <div className="hero">
    // </div>
  );
}

