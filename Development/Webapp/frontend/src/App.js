
// src/App.js
import React, { useEffect, useState } from 'react';

function App() {
  const [dataTitle, setDataTitle] = useState('');
  const [dataBody, setDataBody] = useState('');

  useEffect(() => {
    fetch('http://backend_service:4000/')
      .then((response) => response.json())
      .then((data) => {
        setDataTitle(data.title)
        setDataBody(data.body)
    })
      .catch((error) => console.error('Error:', error));
  }, []);

  return (
    <div>
       <h1 className='centre'>{dataTitle}</h1>
       <h2 className='body'>{dataBody}</h2>
      {/* <p>{data}</p> */}
    </div>
  );
}

export default App;
