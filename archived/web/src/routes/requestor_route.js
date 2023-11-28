import React from "react";
import { Navbar } from "../components/navbar/Navbar";
//import { Footer } from "../components/footer/Footer";
import { HeroImg2 } from "../components/heroImages/HeroImg2";
//import { ContactForm } from "../components/contact/ContactForm";


export const Requestor = ({params}) => {
  return (
    <div>
      <Navbar params={params}/>
      <HeroImg2 heading="Requestor Page" text="This is where you request new cdm information" />
      {/* <ContactForm />
      <Footer /> */}
    </div>
  );
};

