import React, { Component } from "react";
import Logo from "../../assets/logos/governor-plain.png";
import Aragon from "../../assets/logos/aragon.png";
import { medias } from "./medias";
import ReactTypingEffect from "react-typing-effect";
import "./style.scss";

class Footer extends Component {
  render() {
    return (
      <div className="footer-bar">
        <div className="footer-container">
          <div className="upper">
            <div className="navigation">
              <div className="item">
                <div className="header">Applications</div>
                <a href="https://shop.metafactory.ai">Shop</a>
              </div>
              <div className="item">
                <div className="header">Social</div>
                <a href="https://discord.gg/syk4SWmUPu">Discord</a>
                <a href="https://twitter.com/MetaFactory">Twitter</a>
              </div>
              <div className="item">
                <div className="header">Resources</div>
                <a href="https://gov.metafactory.ai/">Forum</a>
              </div>
              <div className="item">
                <img
                  src={Aragon}
                  draggable={false}
                  alt=""
                  onClick={() => window.open("https://aragon.org/", "_blank")}
                />
              </div>
            </div>
            <div className="media">
              <div className="header">Find us</div>
              <div className="items">
                {medias.map((m) => (
                  <a
                    key={m[1]}
                    href={m[2]}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <img src={m[0]} alt={m[1]} />
                  </a>
                ))}
              </div>
            </div>
          </div>
          <div className="bottom">
            <a href="https://metafactory.ai">
              <img src={Logo} alt="" className="logo" />
            </a>
            <div className="footer-typer-container">
              <ReactTypingEffect
                text={[
                  "Hi, I am a quote",
                ]}
                cursorRenderer={(cursor) => (
                  <span className="footer-typer-cursor">{cursor}</span>
                )}
                displayTextRenderer={(text, i) => {
                  return (
                    <div className="footer-typer-text">
                      {text.split("").map((char, index) => {
                        return (
                          <span key={index}>
                            {char !== "_" ? (
                              char
                            ) : (
                              <span className="typer-text-space" />
                            )}
                          </span>
                        );
                      })}
                    </div>
                  );
                }}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default Footer;
