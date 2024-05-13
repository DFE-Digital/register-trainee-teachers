import React from 'react';
import ReactDOM from 'react-dom';
import { RedocStandalone } from 'redoc';

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('redoc-container');
  const apiVersion = container.dataset.apiVersion;
  const apiUrl = `/openapi/${apiVersion}.yaml`;

  ReactDOM.render(
    <RedocStandalone specUrl={apiUrl} />,
    container
  );
});
